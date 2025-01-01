use v6.*;  # because of nano

use Code::Coverable:ver<0.0.3+>:auth<zef:lizmat>;
use String::Utils:ver<0.0.32+>:auth<zef:lizmat> <root>;

class Code::Coverage {
    has @.targets;
    has @.runners;
    has @.extra;
    has $.tmpdir = %*ENV<TMPDIR> // $*HOME;
    has $.slug   = "code-coverage-";
    has $.keep;
    has %.coverables is built(False);
    has %.covered    is built(False);
    has str @!out;
    has str @!err;
    has $!root;

    method TWEAK() {
        @!targets    := @!targets.map(*.IO.absolute).List;
        @!runners    := @!runners.map(*.IO.absolute).List;
        $!tmpdir     := $!tmpdir.IO;
        %!coverables  = coverable-files(@!targets);
        $!root       := root @!targets;
    }

    method run(Code::Coverage:D: *@args) {
        @!out = @!err = ();
        self!cover($_, @args) for @!runners;
        self
    }

    method !cover($runner, @args --> Nil) {
        my $io   := $!tmpdir.add($!slug ~ nano);
        my $path := $io.absolute;
        LEAVE $io.unlink unless $!keep;

        temp %*ENV;
        %*ENV<MVM_COVERAGE_LOG> := $path;
        my $proc := run $*EXECUTABLE, @!extra, $runner, @args, :out, :err;

        my $exit := $proc.exitcode;
        if $exit {
            note "Exited '$runner' with $exit\n$proc.err.slurp.chomp()";
        }

        if @!targets == 1 {
            my $root := "HIT  $!root";
            my $lines := %!covered{$!root} // my int @;
            for $io.lines {
                $lines.push: .substr(.rindex(" ") + 1).Int
                  if .starts-with($root);
            }
            %!covered{$!root} := $lines.sort.squish;
        }

        @!out.push($proc.out.slurp);
        @!err.push($proc.err.slurp);
    }

    method out(Code::Coverage:D:) { @!out.join }
    method err(Code::Coverage:D:) { @!err.join }

    method missed(Code::Coverage:D:) {
        %!coverables.map({
            my $key := .key;
            $key => (.value (-) (%!covered{$key} // ())).keys.sort.List
        }).Map
    }

    method coverage() {
        my %missed := self.missed;
        %!coverables.map({
            my $key := .key;
            if %missed{$key} -> $missed {
                $key => sprintf '%.2f%%', 100 - 100 * $missed.elems / .value
            }
        }).Map
    }
}

=begin pod

=head1 NAME

Code::Coverage - produce code coverage reports

=head1 SYNOPSIS

=begin code :lang<raku>

use Code::Coverage;

my $coverage := Code::Coverage.new(
  targets => @modules,
  runners => @test-scripts
);

$coverage.run;

say .key ~ ": " ~ .value for $coverage.missing;

=end code

=head1 DESCRIPTION

Code::Coverage is a class that contains allows one to run one of
more programs and produce code coverage of one or more targets
(usually modules).

=head1 METHODS

=head2 new

=begin code :lang<raku>

my $cc := Code::Coverage.new(
  targets => @modules,
  runners => @test-scripts,
  extra   => "-I.",    # default: none
  tmpdir  => ".",      # default: %*ENV<TMPDIR> // $*HOME
  slug    => "foobar", # default: "code-coverage-"
  keep    => True,     # default: False
);

$cc.run;
say "$cc.coverage() of code was covered";

=end code

The C<new> method accepts the following named arguments:

=head3 :targets

The C<targets> named argument indicates the paths of one or
more files for which coverage information should be created.

=head3 :runners

The C<runners> named argument indicates the paths of one or
more scripts that should be executed to determine coverage
information.

=head3 :extra

The C<extra> named argument indicates any extra command line
arguments that should be set when calling the C<runners>.
By default, no extra arguments are added.  A typical usage
would be "-I.".

=head3 :tmpdir

The C<tmpdir> named argument specifies the path of the directory
that should be used to store the temporary coverage files.  It
defaults to the C<TMPDIR> environment variable, or the home
directory as known by C<$*HOME>.

=head3 :slug

The C<slug> named argument specifies the prefix of the coverage
files to be created.  It defaults to "code-coverage-".

=head3 :keep

The C<keep> named argument specifies whether the temporary
coverage files should be kept or not.  Defaults to C<False>.

=head2 run

The C<run> method will execute all of the C<:runner> scripts,
gather the coverage information, and update all internal
information as applicable.

Any positional arguments specified will be added as command
line arguments to the C<:runner> scripts.  Note that it is
fully ok to call this method more than once with a different
set of parameters, to test different code paths in the runners.

=head2 out

Returns the collected STDOUT output of all of the C<:runner>
scripts since the last time the C<run> method was executed.

=head2 err

Returns the collected STDERR output of all of the C<:runner>
scripts since the last time the C<run> method was executed.

=head2 coverables

Returns a C<Map> with all of the coverable lines found in
the C<:targets> specified.  Note the keys in the target map
may actually differ from what was specified in C<:targets>
as C<#line> directives may change file names used.

=head2 covered

Returns a C<Map>, keyed by target key, with all of the lines
that appear to have been covered by executing the runners
(possibly multiple times).

=head2 missing

Returns a C<Map>, keyed by target key, with all of the lines
that appear to have B<NOT> been covered by executing the runners
(possibly multiple times).

=head2 coverage

Returns a string with the percentage of lines that were covered
so far by executing the runners (possibly multiple times).

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Code-Coverage . Comments and
Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
