# This script simply contains some code to be executed so that
# coverage can be determined.  Any changes here will break the
# tests in t/01-basic.rakutest, so be warned!

my $a = @*ARGS.shift;

if $a {
    my $b = $a * 2;
    say $b;
}
else {
    say "alas";
}

# vim: expandtab shiftwidth=4
