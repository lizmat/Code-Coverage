use v6.*;  # because of nano

use Code::Coverable:ver<0.0.8+>:auth<zef:lizmat>;

class Code::Coverage {
    has @.targets;
    has @.runners;
    has @.extra;
    has $.repo   = $*REPO;
    has $.tmpdir = %*ENV<TMPDIR> // $*HOME;
    has $.slug   = "code-coverage-";
    has $.keep;
    has %.coverables          is built(False) handles <keys>;
    has $.num-coverable-lines is built(False);
    has %.covered             is built(False);
    has str @!out;
    has str @!err;

    method TWEAK() {
        @!runners    := @!runners.map(*.IO.absolute).List;
        $!tmpdir     := $!tmpdir.IO;

        my @coverables = coverables(@!targets, :$!repo);
        $!num-coverable-lines := @coverables.map(*.line-numbers.elems).sum;
        %!coverables = @coverables.map: { .key => $_ }
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

        for %!coverables.keys -> $key {
            my $lines  := %!covered{$key} // my int @;
            my $needle := "HIT  $key";

            # Don't cache the coverage file lines as these files can
            # become *VERY* big and looping over them just means a bit
            # more CPU usage, but a *LOT* less memory use
            for $io.lines {
                $lines.push: .substr(.rindex(" ") + 1).Int
                  if .starts-with($needle);
            }
            %!covered{$key} := $lines.sort.squish;
        }

        @!out.push($proc.out.slurp);
        @!err.push($proc.err.slurp);
    }

    method out(Code::Coverage:D:) { @!out.join }
    method err(Code::Coverage:D:) { @!err.join }

    method missed(Code::Coverage:D:) {
        %!coverables.map({
            my $key := .key;
            $key => (.value.line-numbers (-) (%!covered{$key} // ()))
                     .keys.sort.List
        }).Map
    }

    method coverage(Code::Coverage:D:) {
        my %missed := self.missed;
        %!coverables.map({
            my $key := .key;
            if %missed{$key} -> $missed {
                $key => sprintf '%.2f%%',
                  100 - 100 * $missed.elems / .value.line-numbers.elems
            }
        }).Map
    }

    method sources(Code::Coverage:D:) {
        %!coverables.map({ .key => .value.source }).Map
    }

    method source(Code::Coverage:D: Str:D $key) {
        (%!coverables{$key} andthen .source) // Nil
    }

    method num-covered-lines(Code::Coverage:D:) {
        %!covered.values.map(*.elems).sum
    }

    method max-lines(Code::Coverage:D:) {
        $!num-coverable-lines max self.num-covered-lines
    }

    method annotated(Code::Coverage:D: Str:D $key) {
        with %!coverables{$key} -> $coverable {
            my uint8 @line-numbers;;
            @line-numbers[$_] = 1 for $coverable.line-numbers;

            my uint8 @covered;
            @covered[$_] = 1 for %!covered{$key} // ();

            my str @parts;
            my int $i;  # effectively start at 1
            for $coverable.source.lines(:!chomp) {
                @parts.push: @covered[++$i]
                  ?? @line-numbers[$i]
                    ?? "* "
                    !! "✱ "
                  !! @line-numbers[$i]
                    ?? "x "
                    !! "  ";
                @parts.push: $_;
            }
            @parts.join
        }
        else {
            Nil
        }
    }
}

# vim: expandtab shiftwidth=4
