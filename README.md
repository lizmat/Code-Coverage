[![Actions Status](https://github.com/lizmat/Code-Coverage/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Code-Coverage/actions) [![Actions Status](https://github.com/lizmat/Code-Coverage/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Code-Coverage/actions) [![Actions Status](https://github.com/lizmat/Code-Coverage/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Code-Coverage/actions)

NAME
====

Code::Coverage - produce code coverage reports

SYNOPSIS
========

```raku
use Code::Coverage;

my $coverage := Code::Coverage.new(
  targets => @modules,
  runners => @test-scripts
);

$coverage.run;

say .key ~ ": " ~ .value for $coverage.missing;
```

DESCRIPTION
===========

Code::Coverage is a class that contains allows one to run one of more programs and produce code coverage of one or more targets (usually modules).

METHODS
=======

new
---

```raku
my $coverage := Code::Coverage.new(
  targets => @modules,
  runners => @test-scripts,
  extra   => "-I.",    # default: none
  tmpdir  => ".",      # default: %*ENV<TMPDIR> // $*HOME
  slug    => "foobar", # default: "code-coverage-"
  keep    => True,     # default: False
);
```

The `new` method accepts the following named arguments:

### :targets

The `targets` named argument indicates the paths of one or more files for which coverage information should be created.

### :runners

The `runners` named argument indicates the paths of one or more scripts that should be executed to determine coverage information.

### :extra

The `extra` named argument indicates any extra command line arguments that should be set when calling the `runners`. By default, no extra arguments are added. A typical usage would be "-I.".

### :tmpdir

The `tmpdir` named argument specifies the path of the directory that should be used to store the temporary coverage files. It defaults to the `TMPDIR` environment variable, or the home directory as known by `$*HOME`.

### :slug

The `slug` named argument specifies the prefix of the coverage files to be created. It defaults to "code-coverage-".

### :keep

The `keep` named argument specifies whether the temporary coverage files should be kept or not. Defaults to `False`.

run
---

The `run` method will execute all of the `:runner` scripts, gather the coverage information, and update all internal information as applicable.

Any positional arguments specified will be added as command line arguments to the `:runner` scripts. Note that it is fully ok to call this method more than once with a different set of parameters, to test different code paths in the runners.

out
---

Returns the collected STDOUT output of all of the `:runner` scripts since the last time the `run` method was executed.

err
---

Returns the collected STDERR output of all of the `:runner` scripts since the last time the `run` method was executed.

coverables
----------

Returns a `Map` with all of the coverable lines found in the `:targets` specified. Note the keys in the target map may actually differ from what was specified in `:targets` as `#line` directives may change file names used.

covered
-------

Returns a `Map`, keyed by target key, with all of the lines that appear to have been covered by executing the runners (possibly multiple times).

missing
-------

Returns a `Map`, keyed by target key, with all of the lines that appear to have **NOT** been covered by executing the runners (possibly multiple times).

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Code-Coverage . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

