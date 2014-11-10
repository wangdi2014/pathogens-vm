#!/usr/bin/env perl
use strict;
use warnings;
use Helper;

if (@ARGV != 1) {
    print STDERR "Usage: $0 <program_info.tsv>\n";
    exit 1;
}

my $all_packages_file = $ARGV[0];
my $package_info = Helper::load_all_packages_info($all_packages_file);

for (sort keys %{$package_info}) {
    print "$_\t" . $package_info->{$_}->get_version() . "\n";
}
