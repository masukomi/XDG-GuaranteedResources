NAME
====

XDG::GuaranteedResources - Guarantees that a module's resource is present in the expected XDG Base Directory directory.


SYNOPSIS
========

Your module's resources should be stored in one of the following directories under `resources`
: `data`, `config`, `cache`, `runtime`, or `state`. These correspond to the common `XDG_BASE_DIRECTORY` directories.

For example, if you have a default config file, you'd store that under `resources/config/` within your module.

Then you can guarantee there's a copy of it in the appropriate `XDG_BASE_DIRECTORY` by calling  `guarantee-config-resource` like this:

```raku
use XDG::GuaranteedResources;

guarantee-config-resource("app_config.toml", My::Resourcer);

```
This will look for `$XDG_CONGIF_HOME/<your app name>/app_config.toml`. If it does not exist, then it will be copied to that location from your module's resources.


Files in subdirectories work as well.

```raku
# module path
# resources/data/user/user_config.toml

# guarante this with this call
guarantee-data-resource("user/user_config.toml", My::Resourcer)

```

You've probably noticed that second argument. Your modules resources are hidden from code outside the module. To work around this you'll need to implement a subclass of `XDG::GuaranteedResources::AbstractResourcer` with 2 simple methods. Here's a sample class. Just change the class name, and make sure `app-name` returns the name of your app. It must be a single string that can be be used as a folder name. 


```raku
    use XDG::GuaranteedResources::AbstractResourcer;

    unit class My::Resourcer does XDG::GuaranteedResources::AbstractResourcer;

    # for XDG::GuaranteedResources::AbstractResourcer
    method app-name(){'my_app';}
    method fetch-resource(::?CLASS:U:){%?RESOURCES;}
```

Once you've got that, you can just pass it in as the 2nd param to either of the provided methods, or assign it to a variable and pass that in.


To guarantee a directory by itself just use the terms from XDG::BaseDirectory.


``` raku
use XDG::BaseDirectory
my $xdg_config_dir = config-home;
unless $xdg_config_dir.IO.e {
  mkdir($xdg_config_dir.Str);
}
```

DESCRIPTION
===========
The intent is to use this in conjunction with modules that have a `resources` directory whose contents are only starting points to be copied out into the appropriate [XDG_BASE_DIRECTORY](https://wiki.archlinux.org/title/XDG_Base_Directory) directory.

For example:  
Many tools expect to have a config file that users will modify, like git's `~/.gitconfig`
Your module could include a copy with all the defaults under `resources/config/my_config.json` and then use this module to guarantee that that exists in the relevant "XDG_BASE_DIRECTORY" location. `guarantee-resource($my_config, $resourcer);` would make sure that `$XDG_CONFIG_DIR/`


Many tools expect a config file, sqlite database, or similar to be present. We store these in the resources listed in `META6.json`, and need to test if they exist and copy them over from `resources` if not.

`XDG::GuaranteedResources` handles this common operation.

For example:

Let's assume your script uses a pre-prepared sqlite db that you store under resources. Store it under `resources/data/my_app/my_database.db`, then when your script boots up you can call `guarantee-resource("data/my_app/my_database.db");`. If that file already exists under `%*ENV<XDG_CONFIG_HOME>/my_app/my_database.db` nothing will happen. If it isn't found there, a fresh copy will be placed there from the one you referenced in `resources`.

Note that `my_app` should be the directory name your apps files should be stored under. For example, a config file for [clu](https://github.com/masukomi/clu) would be stored under `~/.config/clu/` after install. So, you would store it under `resources/config/clu/` in your package.

Resources that should be copied to `XDG_CONFIG_HOME` should be stored under `resources/config/my_app`

Resources that should be copied to `XDG_DATA_HOME` should be stored under `resources/data/my_app`

Subdirectories are fine. E.g. `resources/data/my_app/subdir/my_db.db`

⚠ Currently only works on Unix (Linux, BSD, macOS, etc.) systems.

AUTHOR
======

Kay Rhodes a.k.a masukomi (masukom@masukomi.org)

COPYRIGHT AND LICENSE
=====================

Copyright 2022 

This library is free software; you can redistribute it and/or modify it under the MIT License.

### multi sub guarantee-resource

```raku
multi sub guarantee-resource(
    Str $resource_path,
    $resourcer
) returns Str
```

Guarantees a resource is present & provides the path it can be found at.

### sub guarantee-resources

```raku
sub guarantee-resources(
    @resource_paths,
    $resourcer
) returns Array
```

Guarantees a list of resources are present. Returns the paths they can be found at.

