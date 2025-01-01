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

class Foo {
    has $.a;
    has @.b;
    has %.c;

    method TWEAK() {
        $!a = "foo";
        @!b = "bar";
        %!c = :baz;
    }
}

my $foo = Foo.new(:$a);

if $foo.a eq "foo" {
    $foo.b.push("zippo");
}
else {
    $foo.c = ();
}

# vim: expandtab shiftwidth=4
