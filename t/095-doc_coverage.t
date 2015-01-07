use strict;
use warnings;
use Test::More;
use Config::General;
use Data::Dumper;
use File::Temp qw/tempfile/;

# ensure that all config options are well documented
my $src = 'https://raw.githubusercontent.com/sni/thruk_org/master/documentation/configuration.asciidoc';

plan skip_all => 'skipped by TEST_SKIP_DOC_COVERAGE' if $ENV{TEST_SKIP_DOC_COVERAGE};
plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};

# read our config and enable everything
my $conf = get_thruk_conf();
my $docs = get_docs();
for my $key (keys %{$conf}) {
    next if $key eq 'Component';
    next if $key =~ /^\d+$/mx;
    is($docs->{$key}, 1, "documentation entry for: $key");
}
for my $key (keys %{$conf->{'Component'}}) {
    is($docs->{"Component $key"}, 1, "documentation entry for: $key");
}

done_testing();


sub get_thruk_conf {
    my $conf_string = "";
    open(my $ph, '<', 'thruk.conf') or die("cannot open thruk.conf");
    while(<$ph>) {
    my $line = $_;
        next if $line !~ m/(=\s+|<)/mx;
        $line =~ s/^\s*#//g;
        $conf_string .= $line;
    }
    close($ph);

    $conf = new Config::General(-String => $conf_string, -CComments => 0);
    my %config = $conf->getall;
    return \%config;
}


sub get_docs {
    my($fh, $tmpfile) = tempfile();
    my $doc_header;
    `wget $src -q -O $tmpfile`;
    open(my $ph, '<', $tmpfile) or die("cannot open ".$tmpfile.": ".$!);
    while(<$ph>) {
    my $line = $_;
        if($line =~ m/^===\s+(.*)$/) {
            $doc_header->{$1} = 1;
        }
        if($line =~ m/^==\s+(.*)$/) {
            $doc_header->{$1} = 1;
        }
    }
    close($ph);
    unlink($tmpfile);
    return $doc_header;
}
