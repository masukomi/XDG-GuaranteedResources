NAME
====

XDG::GuaranteedResources - Guarantees that a resource is present in the expected XDG Base Directory directory

SYNOPSIS
========

First, you need to implement a class that can get resources from within your package. I suggest you copy this, and change the class name. Alas, this is not something that another package like this one can provide.

    use XDG::GuaranteedResources::AbstractResourcer;

    unit class My::Resourcer does XDG::GuaranteedResources::AbstractResourcer;

    # for XDG::GuaranteedResources::AbstractResourcer
    method fetch-resource(::?CLASS:U:){%?RESOURCES;}

Once you've got that, you can just pass it in as the 2nd param to either of the provided methods, or assign it to a variable and pass that in.

```raku
use XDG::GuaranteedResources;
# pass it the relative path to a file under your resources directory
# path must be listed in the resources array of your META6.json
guarantee-resource("config/my_app/app_config.toml", My::Resourcer);

# assigning your resourcer to a variable is fine.
my $resourcer = My::Resourcer;
# if you have multiple to guarantee you pass a list to the plural form.
guarantee-resources(<config/my_app/app_config.toml data/my_app/cool_database.db>, $resourcer);
```

DESCRIPTION
===========

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

