#!/usr/bin/env bash
set -e

# biolinux uses zsh by default. Change to bash
sed -i 's"/home/manager:/bin/zsh"/home/manager:/bin/bash"' /etc/passwd


mkdir -p /usr/local/bioinf-recipes

# dnaplotter is installed as part of bio-linux-artemis,
# but is not in user's path so needs fixing
awk '$0~/^ARTEMIS_HOME=/ {$0="ARTEMIS_HOME=/usr/local/bioinf/artemis/artemis/"} {print}' /usr/local/bioinf/artemis/artemis/dnaplotter > tmp
mv tmp /usr/local/bioinf/artemis/artemis/dnaplotter
ln -s -f /usr/local/bioinf/artemis/artemis/dnaplotter /usr/local/bin
chmod 755 /usr/local/bioinf/artemis/artemis/dnaplotter

# add java repository
add-apt-repository ppa:webupd8team/java
apt-get update

# install core modules
for package in \
bamtools \
libbamtools-dev \
check \
cpanminus \
flashplugin-installer \
gdebi \
libboost-iostreams-dev \
libboost-system-dev \
libboost-filesystem-dev \
libcairo2-dev \
libhdf5-dev \
libtool \
libxml2-dev \
oracle-java8-installer \
pandoc \
python-numpy \
python-setuptools \
python3-dev \
python3-numpy \
python3-setuptools \
python3-pip \
prodigal \
sra-toolkit \
aragorn \
libdatetime-perl \
libmysqlclient-dev \
libssl-dev \
libcurl4-openssl-dev
libxml-simple-perl \
parallel \
prank \
mafft \
exonerate \
fasttree \
tabix \
t1-xfree86-nonfree \
ttf-xfree86-nonfree \
ttf-xfree86-nonfree-syriac \
virtualbox-guest-dkms \
xfonts-100dpi \
xfonts-75dpi \
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
Bio::Roary \
Statistics::Descriptive \
GD::Graph::histogram
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
pip install pysam==0.8.3
pip3 install pysam==0.8.3
pip3 install --upgrade setuptools
pip3 install ipython==6.5.0
pip3 install jupyter
pip3 install bash_kernel
pip3 install prompt-toolkit==1.0.15
python3 -m bash_kernel.install
# Need this, otherwise jupyter only works as root
#chown manager:manager -R ~/.local/share/jupyter/
#chown manager:manager -R ~/.ipython/

echo "--------------------- installed Python pip etc ... ------------------------"

touch $HOME/Desktop/README.txt

echo "-------------- installing bioinf packages -------------------"
./install_bioinf_packages.pl all_packages.tsv to_install.txt
chown manager:manager $HOME/Desktop/README.txt

echo "--------------------- installing R packages ... ------------------------"
cwd=$(pwd)
cd /usr/local/bioinf-recipes/

#devtools
wget https://cran.r-project.org/src/contrib/curl_3.2.tar.gz
Rscript -e "install.packages('curl_3.2.tar.gz', repos = NULL, type='source')"

wget https://cran.r-project.org/src/contrib/openssl_1.0.2.tar.gz
Rscript -e "install.packages('openssl_1.0.2.tar.gz', repos = NULL, type='source')"

wget https://www.stats.bris.ac.uk/R/src/contrib/httr_1.3.1.tar.gz
Rscript -e "install.packages('httr_1.3.1.tar.gz', repos = NULL, type='source')"

wget https://www.stats.bris.ac.uk/R/src/contrib/whisker_0.3-2.tar.gz
Rscript -e "install.packages('whisker_0.3-2.tar.gz', repos = NULL, type='source')"

wget https://www.stats.bris.ac.uk/R/src/contrib/git2r_0.23.0.tar.gz
Rscript -e "install.packages('git2r_0.23.0.tar.gz', repos = NULL, type='source')"

wget https://cran.r-project.org/src/contrib/00Archive/devtools/devtools_1.13.6.tar.gz
Rscript -e "install.packages('devtools_1.13.6.tar.gz', repos = NULL, type='source')"

rm git2r_0.23.0.tar.gz devtools_1.13.6.tar.gz whisker_0.3-2.tar.gz httr_1.3.1.tar.gz

#shiny
git clone --branch v0.14 https://github.com/rstudio/shiny.git
pushd shiny && git archive --format=tar.gz --prefix=shiny-0.14/ v0.14 >shiny-0.14.tar.gz && popd
pushd shiny && Rscript -e "install.packages('shiny-0.14.tar.gz', repos = NULL, type='source')" && popd

#shiny-server
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.6.809-amd64.deb
gdebi -n shiny-server-1.4.6.809-amd64.deb

#edgeR
wget https://bioconductor.riken.jp/packages/3.1/bioc/src/contrib/edgeR_3.10.5.tar.gz
Rscript -e "install.packages('edgeR_3.10.5.tar.gz', repos = NULL, type='source')"

#sleuth
wget https://github.com/pachterlab/sleuth/archive/v0.30.0.tar.gz
mv v0.30.0.tar.gz sleuth-v0.30.0.tar.gz
Rscript -e "install.packages('sleuth-v0.30.0.tar.gz', repos = NULL, type='source')"

#DESeq2
wget https://cran.r-project.org/src/contrib/locfit_1.5-9.1.tar.gz
sudo Rscript -e "install.packages('locfit_1.5-9.1.tar.gz', repos = NULL, type='source')"

wget https://cran.r-project.org/src/contrib/00Archive/RcppArmadillo/RcppArmadillo_0.4.200.0.tar.gz
Rscript -e "install.packages('RcppArmadillo_0.4.200.0.tar.gz', repos = NULL, type='source')"

wget http://bioconductor.org/packages/3.1/bioc/src/contrib/DESeq2_1.8.2.tar.gz
Rscript -e "install.packages('DESeq2_1.8.2.tar.gz', repos = NULL, type='source')"

#GenomeScope
wget https://github.com/schatzlab/genomescope/archive/v1.0.0.tar.gz
tar xf v1.0.0.tar.gz
rm v1.0.0.tar.gz
cd /usr/local/bin
ln -s /usr/local/bioinf-recipes/genomescope-1.0.0/genomescope.R genomescope.R

cd $cwd
echo "--------------------- installed R packages ... ------------------------"

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

chown manager:manager ~/.bash_history
