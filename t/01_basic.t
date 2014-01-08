use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
sub xsystem { !system @_ or die "FAIL @_" }

my $tempdir = tempdir CLEANUP => 1;

chdir $tempdir or die;
xsystem "minil new My::App 2>/dev/null";
ok -d "$tempdir/My-App";

chdir "$tempdir/My-App" or die;
xsystem "minil add my.pl";
ok -f "script/my.pl";

xsystem "minil add My::New::App";
ok -f "lib/My/New/App.pm";

xsystem "minil add 01_basic.t";
ok -f "t/01_basic.t";

chdir "lib";
xsystem "minil add my2.pl";
ok -f "../script/my2.pl";

xsystem "minil add My::New::App2";
ok -f "../lib/My/New/App2.pm";

xsystem "minil add 01_basic2.t";
ok -f "../t/01_basic2.t";

chdir "/" or die;


done_testing;

