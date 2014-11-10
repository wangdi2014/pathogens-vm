#!/usr/bin/env perl
use strict;
use warnings;
use Helper;


if ($#ARGV != 1) {
    print STDERR "Usage: $0 <program_info.tsv> <to_install.txt>\n";
    exit 1;
}


my $all_packages_file = $ARGV[0];
my $to_be_installed_file = $ARGV[1];
my $package_info = Helper::load_all_packages_info($all_packages_file);

open F, $to_be_installed_file or die $!;

while (my $line = <F>) {
    next if $line =~ /^#/;
    chomp $line;
    my $prog = $line;
    if (exists $package_info->{$prog}) {
        print "\n----------------- Installing $prog ... --------\n";
        $package_info->{$prog}->install();
        print "\n----------------- Installed $prog -------------\n";
    }
    else{
        warn "\n\nWARNING: program '$prog' not recognised. Cannot install\n\n";
    }

}

close F or die $!;

