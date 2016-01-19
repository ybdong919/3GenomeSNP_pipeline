#!/bin/bash
#$ -S /bin/bash
#$ -N getting_genotype
#$ -j y
#$ -cwd
#$ -R y
#export PATH=$PATH:/home/AAFC-AAC/dongy/mpp/bowtie2-2.2.3/:/home/AAFC-AAC/dongy/mpp/samtools:/home/AAFC-AAC/dongy/mpp/samtools/bcftools

echo "Calling nuclear SNPs is beginning"
bowtie2-build allcontigs.fa bt2ref
ref=allcontigs.fa
samtools faidx $ref

for file1 in CpMtuncontam*1
do

   #echo $file1 
   file2=$(echo ${file1} | sed 's/\.1/\.2/') 
   #echo $file2 
 
   bowtie2 -x bt2ref -1 $file1 -2 $file2 -S $file1.sam --no-unal 
   samtools view -Sbt ${ref}.fai ${file1}.sam > ${file1}.bam
   samtools sort ${file1}.bam ${file1}.sorted
   samtools index ${file1}.sorted.bam
   samtools mpileup -uf $ref ${file1}.sorted.bam | bcftools view -cg -> ${file1}.vcf
   rm *.bai *.bam *.sam

   echo -e "${file1}.vcf" > dirfile
   perl ./Scripts/screen_NuNE_sampleSNP.pl
   rm *step1*.vcf *step2*.vcf
    
done
perl ./Scripts/identify_NuNE_SNP.pl
mv Clean_SNP_Genotypes.txt ./Output_results/Nu_clean_SNP_genotypes.txt
mv Clean_SNP_hap.txt ./Output_results/Nu_clean_SNP_hap.txt
mv All_SNP_Genotypes.txt ./Output_results/Nu_SNP_genotypes.txt
mv All_SNP_hap.txt ./Output_results/Nu_SNP_hap.txt

rm GT_data_without_duplication.txt
rm *.vcf *.bt2 *.fai *name* dirfile *align_contigs All_GTs.txt
rm pre_Clean_SNP_hap.txt

