package Package;

use Moose;
use File::Which;

has 'common_name'    => ( is => 'ro', isa => 'Str', required => 1);
has 'package_name'   => ( is => 'ro', isa => 'Str', required => 1);
has 'install_method' => ( is => 'ro', isa => 'Str', required => 1);
has 'version_cmd'    => ( is => 'ro', isa => 'Str', required => 1);
has 'version_regex'  => ( is => 'ro', isa => 'Str', required => 1);
has 'recipe_dir'    => ( is => 'ro', isa => 'Str', default => 'Recipes');


sub _install_with_linuxbrew {
    my $self = shift;
    my $cmd = "brew install " . $self->package_name;
    system($cmd) and warn "Error: $cmd";
}


sub _install_with_aptget {
    my $self = shift;
    my $cmd = "apt-get install --force-yes --yes " . $self->package_name;
    system($cmd) and warn "Error: $cmd";
}


sub _install_with_recipe {
    my $self = shift;
    my $script = $self->recipe_dir . "/" . $self->common_name;
    system("./$script") and warn "Error: running $script";
}


sub install {
    my $self = shift;
    if ($self->install_method eq "linuxbrew") {
        $self->_install_with_linuxbrew();
    }
    elsif ($self->install_method eq "apt-get") {
        $self->_install_with_aptget();
    }
    elsif ($self->install_method eq "recipe") {
        $self->_install_with_recipe();
    }
    else {
        warn "Unknown install method '" . $self->install_method . "' for program " . $self->common_name;
    }
}


sub get_version {
    my $self = shift;
    my $cmd = $self->version_cmd;
    my $regex = $self->version_regex;
    my $version = "UNKNOWN";
    my @cmd_output = qx($cmd 2>&1);
    foreach (@cmd_output) {
        chomp;
        if (/^$regex$/) {
            $version = $1;
            last;
        }
    }
    return $version;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
