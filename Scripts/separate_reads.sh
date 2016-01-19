#!/bin/bash

mkdir Cp_reads Mt_reads Cp_FASTA_reads Mt_FASTA_reads Cp_index Mt_index
mkdir reads_aligned_to_genome 
mkdir Cp_unique_reads Mt_unique_reads Nu_unique_reads

ref[0]=$(ls ./CpMt_ref_genomes/cp*.fasta)
ref[1]=$(ls ./CpMt_ref_genomes/mt*.fasta)
prefix[0]="Cp"
prefix[1]="Mt"

for ((i=0;i<2;i++))                                    
do
    bowtie2-build ${ref[$i]} refeindex   
	
	for readfile1 in ./Input_data/*R1_001.fastq                 ##### total reads align to Cp or Mt reference genome
    do 
	   parttitle=$(echo ${readfile1%_L001*})
	   sample_prefix=$(echo ${parttitle##*_})
	   
	   readfile2=$(echo ${readfile1} | sed 's/L001_R1_001/L001_R2_001/')
       	   
       bowtie2 -x refeindex -1 $readfile1 -2 $readfile2 --al-conc aligned_${sample_prefix}_${prefix[$i]}.txt -S outfile.sam  
    done
	rm outfile.sam refeindex*
	mv aligned*.txt ./reads_aligned_to_genome
	perl ./Scripts/FastQtoA.pl                                            ##### transfer fastq into fasta 
	
	for file1 in *1.fasta                                       ##### index fasta files
	do
		file2=$(echo ${file1} | sed 's/1\.fasta/2\.fasta/')
		base="contam_"
		base1=$(echo ${file1%_*fasta})
		base2=$(echo ${base1##*_})
		#base2=$(echo ${file1:8:3}|sed 's/_//')
		index=$base$base2
		bowtie2-build $file1,$file2 $index
	done
	
	mv ./reads_aligned_to_genome/aligned*.txt ./${prefix[$i]}_reads/	
	mv aligned*.fasta ./${prefix[$i]}_FASTA_reads/
	mv contam* ./${prefix[$i]}_index/
done

j=2
for ((i=0;i<2;i++))                                              ##### identify unique Cp and Mt reads 
do
	let j=$j-1
	mv ./${prefix[$i]}_reads/aligned*.txt ./
	mv ./${prefix[$j]}_index/contam* ./
	
	for file1 in aligned*.1.txt
	do 
		file2=$(echo ${file1}|sed 's/\.1/\.2/')
		pre="contam_"
		number=$(echo ${file1:8:5}|cut -d'_' -f1)
		index=$pre$number
		clean=${prefix[$i]}"_reads_removing_"${prefix[$j]}$number
		bowtie2 -x $index --un-conc $clean  -1 $file1 -2 $file2 -S outfile.sam
	done
	rm outfile.sam
    mv ./*reads_removing* ./${prefix[$i]}_unique_reads
    mv ./aligned*.txt ./${prefix[$i]}_reads/
	mv ./contam* ./${prefix[$j]}_index/	
done

##### identify unique Nu reads

mv ./Input_data/*fastq ./
mv ./Cp_index/contam* ./
for file1 in *R1_001.fastq
do 
   file2=$(echo ${file1}|sed 's/L001_R1_001/L001_R2_001/')
   pre="contam_"
   numb1=$(echo ${file1%_L001*})
   number=$(echo ${numb1##*_})
   #number=$(echo ${file1}|cut -d'_' -f2)
   index=$pre$number
   clean="Cpuncontam"$number
   bowtie2 -x $index --un-conc $clean  -1 $file1 -2 $file2 -S outfile.sam
done
rm outfile.sam 
mv ./*fastq ./Input_data/
mv ./contam* ./Cp_index/

mv ./Mt_index/contam* ./
for file1 in Cpuncontam*.1
do 
   file2=$(echo ${file1}|sed 's/\.1/\.2/')
   pre="contam_"
   number=$(echo ${file1:10:5}|cut -d'.' -f1)
   index=$pre$number
   clean="CpMtuncontam"$number
   bowtie2 -x $index --un-conc $clean  -1 $file1 -2 $file2 -S outfile.sam
done 
rm outfile.sam Cpuncontam*
mv ./contam* ./Mt_index/
mv ./CpMtuncontam* ./Nu_unique_reads

rm -r Cp_reads Mt_reads Cp_FASTA_reads Mt_FASTA_reads Cp_index Mt_index reads_aligned_to_genome
