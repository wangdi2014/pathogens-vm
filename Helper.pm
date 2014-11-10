package Helper;
use strict;
use warnings;
use Package;

sub load_all_packages_info {
    my $filename = shift;
    my %package_info;

    open F, $filename or die $!;
    while (my $line = <F>) {
        next if ($line =~ /^#/);
        chomp $line;
        my ($common_name, $package_name, $install_method, $version_cmd, $version_regex) = split /\t/, $line;
        if (exists $package_info{$common_name}) {
            warn "Got program $common_name more than once! Only using first one";
            next;
        }
        my $package = Package->new(
            'common_name'    => $common_name,
            'package_name'   => $package_name,
            'install_method' => $install_method,
            'version_cmd'    => $version_cmd,
            'version_regex'  => $version_regex,
        );
        $package_info{$common_name} = $package;
    }
    close F or die $!;
    return \%package_info;
}

1;
