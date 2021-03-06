use strict;
use warnings;

use 5.008001;

use ExtUtils::MakeMaker;

my %RUN_DEPS = (
                 'Clone' => 0,
                 'Scalar::Util' => 0,
               );
my %CONFIGURE_DEPS = (
                       'ExtUtils::MakeMaker' => 0,
                     );
my %BUILD_DEPS = ();

my %TEST_DEPS = (
                  'Test::More' => 0.90,
                );

WriteMakefile1(
                MIN_PERL_VERSION => '5.008001',
                META_ADD         => {
                            'meta-spec' => { version => 2 },
                            resources   => {
                                repository => 'https://github.com/perl5-utils/Hash-Merge',
                                license    => 'http://dev.perl.org/licenses/',
                            },
                            prereqs => {
                                         develop => {
                                                     requires => {
                                                         'Test::CPAN::Changes'                 => 0,
                                                         'Test::CheckManifest'                 => 0,
                                                         'Test::Pod'                           => 0,
                                                         'Test::Pod::Coverage'                 => 0,
                                                         'Test::Pod::Spelling::CommonMistakes' => 0,
                                                     },
                                                    },
                                         configure => {
                                                        requires => {%CONFIGURE_DEPS},
                                                      },
                                         build   => { requires => {%BUILD_DEPS} },
                                         test    => { requires => {%TEST_DEPS} },
                                         runtime => {
                                                      requires => {
                                                                    %RUN_DEPS,
                                                                    perl => '5.8.1',
                                                                  },
                                                    },
                                       },
                            },
                NAME           => 'Hash::Merge',
                VERSION_FROM   => 'lib/Hash/Merge.pm',
                ABSTRACT_FROM  => 'lib/Hash/Merge.pm',
                LICENSE        => 'perl',
                AUTHOR         => q{Michael K. Neylon <mneylon-pm@masemware.com},
                PREREQ_PM      => \%RUN_DEPS,
                BUILD_REQUIRES => \%BUILD_DEPS,
                TEST_REQUIRES  => \%TEST_DEPS,
                test           => { TESTS => 't/*.t xt/*.t' },
              );

sub WriteMakefile1
{    # originally written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params       = @_;
    my $eumm_version = $ExtUtils::MakeMaker::VERSION;
    $eumm_version = eval $eumm_version;
    die "EXTRA_META is deprecated" if ( exists( $params{EXTRA_META} ) );
    die "License not specified"    if ( !exists( $params{LICENSE} ) );
    if ( $params{TEST_REQUIRES} and ( $eumm_version < 6.6303 ) )
    {
        if ( $params{BUILD_REQUIRES} )
        {
            $params{BUILD_REQUIRES} = { %{ $params{BUILD_REQUIRES} }, %{ $params{TEST_REQUIRES} } };
        }
        else
        {
            $params{BUILD_REQUIRES} = delete $params{TEST_REQUIRES};
        }
    }
    if ( $params{BUILD_REQUIRES} and ( $eumm_version < 6.5503 ) )
    {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM} = { %{ $params{PREREQ_PM} || {} }, %{ $params{BUILD_REQUIRES} } };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES}    if ( $eumm_version < 6.52 );
    delete $params{MIN_PERL_VERSION}      if ( $eumm_version < 6.48 );
    delete $params{META_MERGE}            if ( $eumm_version < 6.46 );
    delete $params{META_ADD}{prereqs}     if ( $eumm_version < 6.58 );
    delete $params{META_ADD}{'meta-spec'} if ( $eumm_version < 6.58 );
    delete $params{META_ADD}              if ( $eumm_version < 6.46 );
    delete $params{LICENSE}               if ( $eumm_version < 6.31 );
    delete $params{AUTHOR}                if ( $] < 5.005 );
    delete $params{ABSTRACT_FROM}         if ( $] < 5.005 );
    delete $params{BINARY_LOCATION}       if ( $] < 5.005 );

    # more or less taken from Moose' Makefile.PL
    if ( $params{CONFLICTS} )
    {
        my $ok = CheckConflicts(%params);
        exit(0) if ( $params{PREREQ_FATAL} and not $ok );
        my $cpan_smoker = grep { $_ =~ m/(?:CR_SMOKER|CPAN_REPORTER|AUTOMATED_TESTING)/ } keys %ENV;
        unless ( $cpan_smoker || $ENV{PERL_MM_USE_DEFAULT} || $ENV{SQL_STATEMENT_WARN_UPDATE} )
        {
            sleep 4 unless ($ok);
        }
        delete $params{CONFLICTS};
    }

    WriteMakefile(%params);
}
