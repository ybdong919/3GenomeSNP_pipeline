#!/bin/bash

ref[0]=$(ls ./CpMt_ref_genomes/cp*.fasta)
ref[1]=$(ls ./CpMt_ref_genomes/mt*.fasta)
directory[0]="Cp_unique_reads"
directory[1]="Mt_unique_reads"
prefix[0]="Cp"
prefix[1]="Mt"

for ((i=0;i<2;i++))
do
	mv ./${directory[$i]}/${prefix[$i]}* ./
    cp ${ref[$i]} ./allcontigs.fa
	
	bowtie2-build allcontigs.fa bt2ref
	ref=allcontigs.fa
	samtools faidx $ref

	#for file1 in Cp_reads_removing*.1
	for file1 in ${prefix[$i]}_reads_removing*.1
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
	   perl ./Scripts/screen_CpMt_sampleSNP.pl
	   rm *step1*.vcf *step2*.vcf
		
	done

	perl ./Scripts/identify_CpMt_SNP.pl
	
	cp sorted_All_SNPs.txt ./Output_results/${prefix[$i]}_SNPs.txt
	cp Clean_SNPs.txt ./Output_results/${prefix[$i]}_clean_SNPs.txt
	rm *.vcf *.bt2 *.fai *name* dirfile *align_contigs 
	rm allcontigs.fa
	rm SNP_data_without_verthreshold_missing.txt *All_SNPs.txt Clean_SNPs.txt
	echo -e "${prefix[$i]} SNP is finished"
	
	mv ./${prefix[$i]}_reads* ./${directory[$i]}/	
done