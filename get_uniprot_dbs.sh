#!/usr/bin/env bash
set -e

db_dir=/usr/local/databases
mkdir $db_dir
cd $db_dir

ftp=ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/


# eukaryote database
for f in \
uniprot_sprot_fungi.dat.gz \
uniprot_sprot_human.dat.gz \
uniprot_sprot_invertebrates.dat.gz \
uniprot_sprot_mammals.dat.gz \
uniprot_sprot_plants.dat.gz \
uniprot_sprot_rodents.dat.gz \
uniprot_sprot_vertebrates.dat.gz
do
    wget $ftp/$f
done

zcat uniprot_sprot_* > uniprot_eukaryota.sw
seqret uniprot_eukaryota.sw uniprot_eukaryota

echo '</usr/local/databases
uniprot_eukaryota 0' > uniprot_eukaryota.nam
formatdb -p T -i uniprot_eukaryota
rm formatdb.log


# bacteria database
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/uniprot_sprot_bacteria.dat.gz
zcat uniprot_sprot_bacteria.dat.gz > uniprot_bacteria.sw
seqret uniprot_bacteria.sw uniprot_bacteria

echo '</usr/local/databases
uniprot_bacteria 0' > uniprot_bacteria.nam
formatdb -p T -i uniprot_bacteria
rm formatdb.log


#rm *.gz

echo 'BLASTDB=/usr/local/databases
BLASTMAT=/usr/share/ncbi/data
FASTLIBS=/usr/local/databases/pubseqsgbs
' >> /etc/environment

# BLASTDB in /etc/environment gets overwritten by /etc/profile.d/blast_environment.sh
echo 'export BLASTDB=/usr/local/databases' >> /etc/profile.d/blast_environment.sh

echo 'UNIPROT_BACTERIA$0B@/usr/local/databases/uniprot_bacteria.nam 12
UNIPROT_EUKARYOTA$0E@/usr/local/databases/uniprot_eukaryota.nam 12' > pubseqsgbs

sed -i 's/fasta34/fasta36_t/g' /usr/local/bioinf/artemis/etc/run_fasta

