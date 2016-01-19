#!/bin/bash
#$ -S /bin/bash
#$ -N getting_genotype
#$ -j y
#$ -cwd
#$ -R y
#export PATH=$PATH:/home/AAFC-AAC/dongy/mpp/bowtie2-2.2.3/:/home/AAFC-AAC/dongy/mpp/samtools:/home/AAFC-AAC/dongy/mpp/samtools/bcftools

echo "Generating contigs is beginning"
samnum=$(ls -L CpMtuncontam*1|wc -l)
samnum=$(printf "%.0f" $(echo "scale=2;$samnum*0.75"|bc))
for file1 in CpMtuncontam*1
do
  fastx_collapser -Q33 -i $file1 -o $file1.fx 
done

ls -L *.fx > fx-list.txt
minia fx-list.txt 100 $samnum 300000000 fx                  
mv fx.contigs.fa allcontigs.fa
cp allcontigs.fa ./Output_results/Nu_contigs.fasta
rm *.fx fx* 
echo "Generating contigs is finished"



