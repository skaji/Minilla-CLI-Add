package Minilla::CLI::Add;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.001";

use Data::Section::Simple;
use File::Basename qw(dirname);
use File::Path qw(mkpath);
use File::Spec::Functions qw(catfile);
use File::pushd qw(pushd);
use Minilla::Logger;
use Minilla::Project;
use Minilla::Util qw(parse_options spew_raw);

use Moo;
has main_module => ( is => 'rw' );
has module      => ( is => 'rw' );
has path        => ( is => 'rw' );
has script      => ( is => 'rw' );
no Moo;

sub to_module {
    my (undef, $path) = @_;
    $path =~ s{/}{::}g;
    $path =~ s{\.pm}{};
    $path;
}

sub to_path {
    my (undef, $module) = @_;
    $module =~ s{::}{/}g;
    $module .= ".pm" if $module !~ /\.pm$/;
    $module;
}

sub run {
    my ($class, $file) = @_;
    # XXX accept --type (pl|t|pm) option?

    my $project = Minilla::Project->new;
    my $dir = $project->dir;
    my $main_module = do {
        my $guard = pushd $dir;
        my ($path) = $project->main_module_path =~ m{^lib/(.+)};
        $class->to_module($path);
    };
    my $self = $class->new( main_module => $main_module );

    if (my ($script) = $file =~ /(.+)\.pl$/) {
        $self->script($script);
        $self->render('script.pl', catfile("$dir/script", $file));
    }
    elsif ($file =~ /(.+)\.t$/) {
        $self->render('test.t', catfile("$dir/t", $file));
    }
    else {
        my $path   = $self->to_path($file);
        my $module = $self->to_module($file);
        $self->module($module);
        $self->render('Module.pm', catfile("$dir/lib", $path));
    }

}


# taken from Minilla::Profile::Base::render
sub render {
    my ($self, $tmplname, $path) = @_;

    infof("Writing %s\n", $path);
    mkpath(dirname($path));

    my $content = Data::Section::Simple->new->get_data_section($tmplname);
    $content =~ s/^    //smg;
    $content =~ s!<%\s*\$([a-z_]+)\s*%>!
        $self->$1()
    !ge;
    spew_raw($path, $content);
}

1;
__DATA__

@@ Module.pm
    package <% $module %>;
    use 5.008005;
    use strict;
    use warnings;


    1;
    __END__

    =encoding utf-8

    =head1 NAME

    <% $module %> - hogehoge

    =head1 SYNOPSIS

        use <% $module %>;

    =cut

@@ script.pl
    #!perl
    use 5.008005;
    use strict;
    use warnings;


    __END__

    =encoding utf-8

    =head1 NAME

    <% $script %>.pl

    =head1 SYNOPSIS

        % perl <% $script %>.pl

    =cut

@@ test.t
    use strict;
    use warnings;
    use Test::More;

    use <% $main_module %>;


    done_testing;

__END__

=encoding utf-8

=head1 NAME

Minilla::CLI::Add - minil add command

=head1 SYNOPSIS

    % minil add Addtional::Module
    % minil add new-script.pl
    % minil add new-test.t

=head1 DESCRIPTION

Minilla::CLI::Add adds minil add command.

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@outlook.comE<gt>

=cut

