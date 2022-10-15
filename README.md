NAME
====

XDG::GuaranteedResources - Guarantees that a resource is present in the expected XDG Base Directory directory

SYNOPSIS
========

```raku
use XDG::GuaranteedResources;
# pass it the relative path to a file under your resources directory
# path must be listed in the resources array of your META6.json
guarantee-resource("config/app_config.toml");
```

DESCRIPTION
===========

Many tools expect a config file, sqlite database, or similar to be present. We store these in the resources listed in `META6.json`, and need to test if they exist and copy them over from `resources` if not.

`XDG::GuaranteedResources` handles this common operation.

Resources that should be copied to `XDG_CONFIG_HOME` should be stored under `resources/config`

Resources that should be copied to `XDG_DATA_HOME` should be stored under `resources/data`

Subdirectories are fine. E.g. `resources/data/subdir/my_db.db`

⚠ Currently only works on Unix (Linux, BSD, macOS, etc.) systems.

AUTHOR
======

Kay Rhodes a.k.a masukomi (masukom@masukomi.org)

COPYRIGHT AND LICENSE
=====================

Copyright 2022 

This library is free software; you can redistribute it and/or modify it under the MIT License.

### sub guarantee-resource

```raku
sub guarantee-resource(
    Str $resource_path
) returns Str
```

checks if the resource is present and copies it over if not.
