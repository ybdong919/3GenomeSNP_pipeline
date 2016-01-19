#!/bin/bash
#$ -S /bin/bash
#$ -N getting_genotype
#$ -j y
#$ -cwd
#$ -R y
#export PATH=$PATH:/home/AAFC-AAC/dongy/mpp/bowtie2-2.2.3/:/home/AAFC-AAC/dongy/mpp/samtools:/home/AAFC-AAC/dongy/mpp/samtools/bcftools

echo "Selecting exon-contigs is beginning"
cat ./Pep_database/*.fa > 38plants_pep.fa
makeblastdb -dbtype prot -in 38plants_pep.fa
echo "blastx is running"
blastx -query allcontigs.fa  -db 38plants_pep.fa -out blastresults.txt -outfmt 10
echo "blastx is finished"
for speciestitle in ./Pep_database/*.fa
do
  grep ">" $speciestitle >> $speciestitle.title
done
mv ./Pep_database/*.title ./
perl ./Scripts/select_exon_contigs.pl
cp exoncontigs.fa ./Output_results/NE_contigs.fasta
rm 38plants_pep* blastresults.txt associated_pep_titles.txt associated_subject_id.txt 
echo "Selecting exon-contigs is finished"

