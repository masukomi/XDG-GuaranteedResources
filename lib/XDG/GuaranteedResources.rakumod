=begin pod

=head1 NAME

XDG::GuaranteedResources - Guarantees that a resource is present in the expected XDG Base Directory directory

=head1 SYNOPSIS


=begin code :lang<raku>

use XDG::GuaranteedResources;
# pass it the relative path to a file under your resources directory
# path must be listed in the resources array of your META6.json
guarantee-resource("config/my_app/app_config.toml");

# if you have multiple to guarantee you pass a list to the plural form.
guarantee-resources(<config/my_app/app_config.toml data/my_app/cool_database.db>);
=end code

=head1 DESCRIPTION

Many tools expect a config file, sqlite database, or similar to be present. We store these in the resources listed in C<META6.json>, and need to test if they exist and copy them over from C<resources> if not.

C<XDG::GuaranteedResources> handles this common operation.

=para
For example:
=para
Let's assume your script uses a pre-prepared sqlite db that you store under resources. Store it under C<resources/data/my_app/my_database.db>, then when your script boots up you can call C<guarantee-resource("data/my_app/my_database.db");>. If that file already exists under C<%*ENV<XDG_CONFIG_HOME>/my_app/my_database.db> nothing will happen. If it isn't found there,
a fresh copy will be placed there from the one you referenced in C<resources>.

Note that C<my_app> should be the directory name your apps files should be stored under. For example, a config file for L<clu|https://github.com/masukomi/clu> would be stored under C<~/.config/clu/> after install. So, you would store it under C<resources/config/clu/> in your package.

Resources that should be copied to C<XDG_CONFIG_HOME>
should be stored under C<resources/config/my_app>

Resources that should be copied to C<XDG_DATA_HOME>
should be stored under C<resources/data/my_app>

Subdirectories are fine. E.g. C<resources/data/my_app/subdir/my_db.db>

⚠ Currently only works on Unix (Linux, BSD, macOS, etc.) systems.

=head1 AUTHOR

Kay Rhodes a.k.a masukomi (masukom@masukomi.org)

=head1 COPYRIGHT AND LICENSE

Copyright 2022 

This library is free software; you can redistribute it and/or modify it under the MIT License.

=end pod


unit module XDG::GuaranteedResources:ver<1.1.1>:auth<masukomi (masukomi@masukomi.org)>;

use XDG::BaseDirectory :terms;
use XDG::GuaranteedResources::Resourcer;


my sub guarantee-dir(Str $dir){
	mkdir($dir.Str) unless $dir.IO.e;
	CATCH {
		when X::IO::Mkdir { die "Unable to create directory $dir" ; }
	}
}

my sub xdg-home-for-dir_array(@directory_array){
	given @directory_array.first {
		when $_ eq 'config' {
			config-home
		}
		when $_ eq 'data' {
			data-home
		}
		default {
			die("resources must be stored under config or data subdirectory");
		}
	}
}

my sub path-to-directory-array(IO::Path $path, @directory_array = [] ) {
	my $parent = $path.parent;
	# TODO: UNIX limitation. Need good way to determine path separator
	return @directory_array if $parent.Str eq '/' or $parent.Str eq '.';
	@directory_array.unshift($parent.basename);
	path-to-directory-array($parent, @directory_array);
}

my sub resource-to-xdg-dir(@directory_array) returns Str {
	# experting directory_array to be something like
	# ["config", "foo.txt"]
	# ["convig", "subdir", "foo.txt"]
	my $home_dir = xdg-home-for-dir_array(@directory_array);
	# TODO: UNIX limitation. Need good way to determine path separator
	my $joined_subpath = @directory_array.elems == 2
						  ?? @directory_array[1]
						  !! @directory_array[1..∞].join("/");
	IO::Spec::Unix.catpath($, $home_dir.Str, $joined_subpath)
}


my sub copy-resource(Str $resource, Str $destination) {
	copy(XDG::GuaranteedResources::Resourcer.gimme{$resource}, $destination);
}

#| Guarantees a resource is present & provides the path it can be found at.
our sub guarantee-resource(Str $resource_path) is export returns Str {
	my $io_path = $resource_path.IO;
	my @dir_array = path-to-directory-array($io_path);
	my $xdg_dir = resource-to-xdg-dir(@dir_array);
	guarantee-dir($xdg_dir);
	my $xdg_path = IO::Spec::Unix.catpath($, $xdg_dir, $io_path.basename);
	unless $xdg_path.IO.e {
		copy-resource($resource_path, $xdg_path);
	}
	return $xdg_path;

	CATCH {
		when X::IO::Copy  { die "Unable to copy resource to $xdg_path"; }
	}

}

#| Guarantees a list of resources are present. Returns the paths they can be found at.
our sub guarantee-resources(@resource_paths)  is export returns Array {
	my @response = [];
	for @resource_paths -> $resource_path {
		@response.push(guarantee-resource($resource_path));
	}
	return @response;
}
