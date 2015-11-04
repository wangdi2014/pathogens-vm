#!/usr/bin/env bash
set -e

# biolinux uses zsh by default. Change to bash
sed -i 's"/home/manager:/bin/zsh"/home/manager:/bin/bash"' /etc/passwd


apt-get update
apt-get upgrade

mkdir -p /usr/local/bioinf-recipes

# dnaplotter is installed as part of bio-linux-artemis,
# but is not in user's path so needs fixing
awk '$0~/^ARTEMIS_HOME=/ {$0="ARTEMIS_HOME=/usr/local/bioinf/artemis/artemis/"} {print}' /usr/local/bioinf/artemis/artemis/dnaplotter > tmp
mv tmp /usr/local/bioinf/artemis/artemis/dnaplotter
ln -s -f /usr/local/bioinf/artemis/artemis/dnaplotter /usr/local/bin
chmod 755 /usr/local/bioinf/artemis/artemis/dnaplotter


# install core modules
for package in \
bamtools \
libbamtools-dev \
check \
cpanminus \
flashplugin-installer \
libboost-iostreams-dev \
libboost-system-dev \
libboost-filesystem-dev \
libtool \
python-numpy \
python-setuptools \
python3-dev \
python3-numpy \
python3-setuptools \
python3-pip \
prodigal \
aragorn \
libdatetime-perl \
libxml-simple-perl \
parallel \
fasttree \
prank \
mafft \
exonerate \
fasttree \
tabix \
virtualbox-guest-dkms \
zerofree
do
    echo
    echo "----------------------- installing $package ... ----------------------"
    echo
    apt-get install -y $package
    echo
    echo "----------------------- installed $package ---------------------------"
    echo
done


# Perl modules
for module in \
File::Which \
File::Spec::Link \
Moose \
Bio::Roary
do
    echo
    echo "--------------------- installing Perl $module ... ----------------------"
    echo
    cpanm $module
    echo
    echo "--------------------- installed Perl $module ---------------------------"
    echo
done


echo "--------------------- installing Python pip etc ... ------------------------"
easy_install pip
pip install pysam
pip3 install pysam
pip3 install jupyter
pip3 install bash_kernel
python3 -m bash_kernel.install
echo "--------------------- installed Python pip etc ... ------------------------"

touch $HOME/Desktop/README.txt

echo "-------------- installing bioinf packages -------------------"
./install_bioinf_packages.pl all_packages.tsv to_install.txt
chown manager:manager $HOME/Desktop/README.txt


echo "-------------- adding desktop shortcuts ---------------------"
echo "[Desktop Entry]
Name=Artemis
Comment=
Exec=/usr/local/bin/art
Icon=/usr/local/bioinf/artemis/artemis/images/icon.gif
Terminal=false
Type=Application
StartupNotify=true" > ~/Desktop/artemis.desktop
chmod 755 ~/Desktop/artemis.desktop

echo "[Desktop Entry]
Name=ACT
Comment=
Exec=/usr/local/bin/act
Icon=/usr/local/bioinf/artemis/act_icon.gif
Terminal=false
Type=Application
StartupNotify=true" > ~/Desktop/act.desktop
chmod 755 ~/Desktop/act.desktop

chown manager:manager ~/Desktop/artemis.desktop ~/Desktop/act.desktop
./get_uniprot_dbs.sh

# shared folders belong to the group "vboxsf".
# Need to add the user manager to this group, so shared folders work
usermod -a -G vboxsf manager
