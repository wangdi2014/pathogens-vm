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
libhdf5-dev \
libtool \
libxml2-dev \
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
libxml-simple-perl \
parallel \
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
pip3 install jupyter
pip3 install bash_kernel
python3 -m bash_kernel.install
# Need this, otherwise jupyter only works as root
chown manager:manager -R ~/.local/share/jupyter/
chown manager:manager -R ~/.ipython/

echo "--------------------- installed Python pip etc ... ------------------------"

touch $HOME/Desktop/README.txt

echo "-------------- installing bioinf packages -------------------"
./install_bioinf_packages.pl all_packages.tsv to_install.txt
chown manager:manager $HOME/Desktop/README.txt

echo "--------------------- installing R packages ... ------------------------"
Rscript -e "install.packages(c('httpuv', 'mime', 'jsonlite', 'htmltools', 'R6', 'sourcetools', 'xtable', 'ggplot2', 'dplyr', 'data.table', 'tidyr', 'reshape2', 'lazyeval', 'RcppArmadillo', 'Hmisc', '\
XML'), repos='http://www.stats.bris.ac.uk/R/')"
Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite(c('rhdf5', 'S4Vectors', 'IRanges', 'GenomicRanges', 'Biobase', 'BiocParallel', 'genefilter', 'geneplotter'))"

cwd=$(pwd)
cd /usr/local/bioinf-recipes/
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
wget https://github.com/pachterlab/sleuth/archive/v0.28.1.tar.gz
mv v0.28.1.tar.gz sleuth-v0.28.1.tar.gz
Rscript -e "install.packages('sleuth-v0.28.1.tar.gz', repos = NULL, type='source')"

#DESeq2
wget https://cran.r-project.org/src/contrib/00Archive/RcppArmadillo/RcppArmadillo_0.4.200.0.tar.gz
Rscript -e "install.packages('RcppArmadillo_0.4.200.0.tar.gz', repos = NULL, type='source')"
wget http://bioconductor.org/packages/3.1/bioc/src/contrib/DESeq2_1.8.2.tar.gz
Rscript -e "install.packages('DESeq2_1.8.2.tar.gz', repos = NULL, type='source')"

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
