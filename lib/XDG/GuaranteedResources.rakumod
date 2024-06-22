unit module XDG::GuaranteedResources:ver<2.1.0>:auth<masukomi (masukomi@masukomi.org)>;

use XDG::BaseDirectory :terms;


my sub guarantee-dir(Str $dir, Bool :$debug){
	if $dir.IO.e {
		note("XDG Dir already exits: $dir") if $debug
	} else {
		mkdir($dir.Str);
	}
	CATCH {
		when X::IO::Mkdir { die "Unable to create directory $dir" ; }
	}
}

multi sub guarantee-data-resource(Str $path, $resourcer, Bool :$debug=False) is export returns Str {
	guarantee-resource('data', $path, $resourcer);
}
multi sub guarantee-config-resource(Str $path, $resourcer, Bool :$debug=False) is export returns Str {
	guarantee-resource('config', $path, $resourcer);
}
multi sub guarantee-cache-resource(Str $path, $resourcer, Bool :$debug=False) is export returns Str {
	guarantee-resource('cache', $path, $resourcer);
}
multi sub guarantee-runtime-resource(Str $path, $resourcer, Bool :$debug=False) is export returns Str {
	guarantee-resource('runtime', $path, $resourcer);
}
multi sub guarantee-state-resource(Str $path, $resourcer, Bool :$debug=False) is export returns Str {
	guarantee-resource('state', $path, $resourcer);
}



#| Guarantees a resource is present & provides the path it can be found at.
multi sub guarantee-resource(Str $which_xdg_home, Str $resource_path,
							 $resourcer, #= must implement XDG::GuaranteedResource::AbstractResourcer
							 Bool :$debug=False
							) returns Str {
	my $io_path = $resource_path.IO;
	# catpath: https://docs.raku.org/type/IO/Spec/Unix#method_catpath
	my $xdg_home = do given $which_xdg_home {
		when 'data' { data-home }
		when 'config' { config-home }
		when 'cache' { data-home }
		when 'runtime' { data-home }
		when 'state' { data-home }
		default { die("Unknown XDG Home: $which_xdg_home") }
	}
	guarantee-dir($xdg_home.Str, debug => $debug);
	my $xdg_path = IO::Spec::Unix.catpath($, $xdg_home.Str, $io_path.basename);
	if $xdg_path.IO.e {
		note("$resource_path already present") if $debug;
	} else {
		note($io_path.basename ~ " missing from target dir") if $debug;
		note("Copying $resource_path to $xdg_path") if $debug;
		my $module_resource_path = IO::Spec::Unix.catpath($, $which_xdg_home, $resource_path);
		my $actual_resource_path = $resourcer.fetch-resource{$module_resource_path};
		die("$resource_path doesn't exist in resources") if $actual_resource_path.comb ~~ Empty;
		copy($resourcer.fetch-resource{$module_resource_path}, $xdg_path);
	}
	return $xdg_path;

	CONTROL {
		when CX::Warn {
			die("$resource_path was not defined in your META6.json ");
		}
	}
	CATCH {
		when X::IO::Copy  { die "Unable to copy resource to $xdg_path"; }
	}

}


=begin pod

=head1 NAME

XDG::GuaranteedResources - Guarantees that a resource is present in the expected XDG Base Directory directory

=head1 SYNOPSIS


First, you need to implement a class that can get resources from within your package. I suggest you copy this, and change the class name. Alas, this is not something that another package like this one can provide.

=begin code
use XDG::GuaranteedResources::AbstractResourcer;

unit class My::Resourcer does XDG::GuaranteedResources::AbstractResourcer;

# for XDG::GuaranteedResources::AbstractResourcer
method fetch-resource(::?CLASS:U:){%?RESOURCES;}

=end code

Once you've got that, you can just pass it in as the 2nd param to either of the provided methods, or assign it to a variable and pass that in.

=begin code :lang<raku>



use XDG::GuaranteedResources;
# Your module's resources are stored in one of the following directories under `resources`
# `data`, `config`, `cache`, `runtime`, or `state`.
# These correspond to the common `XDG_BASE_DIRECTORY` directories.
# call guarantee-<type>-resource(...) with the relative path to
# the resourc (under the appropriate type directory), and your Resourcer.
#
# full resource path must be listed in the resources array of your META6.json
guarantee-config-resource("app_config.toml", My::Resourcer);

# assigning your resourcer to a variable is fine.
my $resourcer = My::Resourcer;
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
