use strict;
use warnings;
use lib qw[../../lib ../../blib/lib];
use Test::More;    # Requires 0.94 as noted in Build.PL
use File::Temp qw[tempfile];
use Template::Liquid;
use Template::Solution::Tag::Include;
note 'chdir to ./t/0200_tags '
    . (chdir './t/0200_tags/' ? 'okay' : 'failed ' . $!)
    if !-d '_includes';

if (!-d '_includes') {
    diag 'Failed to find include directory';
    done_testing();
    exit 0;
}
#
is( Template::Liquid->parse(
           <<'INPUT')->render(), "Testing!\r\n\n", 'Include static filename');
{%include 'testing.inc'%}
INPUT
is( Template::Liquid->parse(
        <<'INPUT')->render(include => 'testing.inc'), "Testing!\r\n\n", 'Include dynamic filename');
{%include include%}
INPUT
is( Template::Liquid->parse(
        <<'INPUT')->render(), <<'EXPECTED', 'Undefined filenames cause error');
{%include missing%}
INPUT

EXPECTED
is( Template::Liquid->parse(
        <<'INPUT')->render(), <<'EXPECTED', 'Non existing filenames cause error');
{%include 'missing' %}
INPUT

EXPECTED

# I'm finished
done_testing();
