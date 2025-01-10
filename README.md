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

say .key ~ ": " ~ .value for $coverage.missed;
```

DESCRIPTION
===========

Code::Coverage is a class that contains the logic to run one or more Raku programs and produce code coverage of one or more targets (usually modules).

METHODS
=======

new
---

```raku
my $cc := Code::Coverage.new(
  targets => @modules,
  runners => @test-scripts,
  extra   => "-I.",    # default: none
  repo    => $repo,    # default: $*REPO
  tmpdir  => ".",      # default: %*ENV<TMPDIR> // $*HOME
  slug    => "foobar", # default: "code-coverage-"
  keep    => True,     # default: False
);

$cc.run;
say "$cc.coverage() of code was covered";
```

The `new` method accepts the following named arguments:

### :targets

The `targets` named argument indicates one or more targets for which coverage information should be created. Each of these can be specified as a path (either as string, or as an `IO::Path` object), or as a `use` target (identity) such as "`String::Utils`".

Whatever was specified, will be returned by the `targets` method.

### :runners

The `runners` named argument indicates the paths of one or more scripts that should be executed to determine coverage information. It should specify at least one script.

Whatever was specified, will be returned by the `runners` method.

### :extra

The `extra` named argument indicates any extra command line arguments that should be set when calling the `:runners` scripts. By default, no extra arguments are added. A typical usage would be "-I." to ensure that the current source of a module is used.

Whatever was specified, will be returned by the `extra` method.

### :repo

The `repo` named argument indicates the `CompUnit::Repository` object to be used when coverable lines are being deduced from bytecode. It defaults to `$*REPO`, aka the default repository chain.

Whatever was specified, will be returned by the `repo` method.

### :tmpdir

The `tmpdir` named argument specifies the path of the directory that should be used to store the temporary coverage files. It defaults to the `TMPDIR` environment variable, or the home directory as known by `$*HOME`.

Whatever was (implicitely) specified, will be returned by the `tmpdir` method.

### :slug

The `slug` named argument specifies the prefix of the coverage files to be created. It defaults to "code-coverage-".

Whatever was (implicitely) specified, will be returned by the `slug` method.

### :keep

The `keep` named argument specifies whether the temporary coverage files should be kept or not. Defaults to `False`, which means that any coverage files will be removed after each call to `.run`.

Whatever was (implicitely) specified, will be returned by the `keep` method.

run
---

```raku
$cc.run("foo");  # test the "foo" code path
$cc.run("bar");  # test the "bar" code path
```

The `run` method will execute all of the `:runners` scripts, gather the coverage information, and update all internal information as applicable.

Any positional arguments specified will be added as command line arguments to the `:runners` scripts. Note that it is fully ok to call this method more than once with a different set of parameters, to test different code paths in the runners.

out
---

```raku
print $cc.out;
```

The `out` method returns the collected STDOUT output of all of the `:runners` scripts since the last time the `run` method was executed.

err
---

```raku
print $cc.err;
```

The `err` method returns the collected STDERR output of all of the `:runners` scripts since the last time the `run` method was executed.

coverables
----------

```raku
for $cc.coverables.values {
    say .source.relative;
    say .line-numbers;
}
```

The `coverables` method returns a `Map` with [`Code::Coverable`](https://raku.land/zef:lizmat/Code::Coverable) objects created for the `:targets` specified, keyed by coverage key that will appear in coverage logs.

keys
----

```raku
say "Coverage keys:";
.say for $cc.keys;
```

The `keys` method returns the coverage keys that were found for the given targets.

covered
-------

```raku
say "Lines covered";
for $cc.covered {
    say .key ~ ":\n$_.value.join(',')\n";
}
```

The `covered` method returns a `Map`, keyed by coverage key, with all of the lines that appear to have been covered by executing the runner scripts (possibly multiple times).

missing
-------

```raku
say "Lines NOT covered";
for $cc.missing {
    say .key ~ ":\n$_.value.join(',')\n";
}
```

The `missing` method returns a `Map`, keyed by coverage key, with all of the lines that appear to have **NOT** been covered by executing the runners (possibly multiple times).

coverage
--------

```raku
say "Coverage:"
for $cc.missing {
    say .key ~ ": " ~ .value;
}
```

The `coverage` method returns a `Map`, keyed by coverage key, with as value a string containing the percentage of lines that were covered so far by executing the runners (possibly multiple times).

sources
-------

```raku
say "Source files:"
for $cc.sources {
    say .key ~ ": " ~ .value.absolute;
}
```

The `sources` method returns a `Map`, keyed by coverage key, with an `IO::Path` object for the associated source file as the value.

source
------

```raku
say "$key: $cc.source($key).relative";
```

The `source` method returns an `IO::Path` object for the source file associated with the given coverage key.

annotated
---------

```raku
print $cc.annotated($key);
```

The `annotated` method produces the contents of the source-file indicated by the coverage key, with each line annotated with the coverage result. The following annotations are given:

  * `*` - line was coverable, and covered

  * `✱` - line was **not** coverable, but covered anyway

  * `x` - line was coverable and **not** covered

  * `` - line was not coverable

num-coverable-lines
-------------------

```raku
say $cc.num-coverable-lines;
```

The `num-coverable-lines` method returns the total number of lines that are marked coverable in all coverage keys.

num-covered-lines
-----------------

```raku
say $cc.num-covered-lines;
```

The `num-covered-lines` method returns the total number of lines that are marked covered in all coverage keys.

num-missed-lines
----------------

```raku
say $cc.num-missed-lines;
```

The `num-missed-lines` method returns the total number of lines that are marked coverable, but have not been covered in all coverage keys (yet).

max-lines
---------

```raku
say $cc.max-lines; # max number of lines that can be covered
```

The `max-lines` method returns the maximum number of lines that can be covered. In some edge cases, this may actually be greater than the number of lines that are marked coverable because some lines may appear in the coverage log that were **not** marked as coverable.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Code-Coverage . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

