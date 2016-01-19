Getting Started with 3GenomeSNP

Steps to Use 3GenomeSNP:
1. Familiarize yourself with 3GenomeSNP by reading Getting Started with 3GenomeSNP.txt (this file) attached in the pipeline folder.
2. Install all required free software, set up paths to access those computer programs, and test if installed software is working by typing: minia, bowtie2, SAMtools, blast or perl separately.
3. Create a directory for the 3GenomeSNP pipeline and copy the whole pipeline to this directory.
4. Upload all FASTQ data into the subfolder “Input_data”.
5. If needed, adjust the related parameters for the output files NE_contigs.fasta by editing Pident_Plength.txt or removing SNP sites with missing by editing Missing_threshold.txt in the subfolder “Threshold_set”. 
6. Start the pipeline by running the shell file 3GenomeSNP.sh by typing: ./3GenomeSNP.sh at the command prompt.
7. Fifteen output files are generated in the subfolder “Output_results” in the same directory of 3GenomeSNP. 

Prerequisite:
1) Minia (http://minia.genouest.org/). Extend k-mer length to 100 by typing: make clean && make k=100
2) Bowtie2 (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
3) SAMtools (http://samtools.sourceforge.net/) 
4) Perl in Linux (http://www.perl.org/get.html)
5) Fastx_collapser (http://hannonlab.cshl.edu/fastx_toolkit/). Download it to the same directory of Minia.
6) Blast+( http://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).
                
Input files:
1) Paired-end Illumina sequencing data files with FASTQ format are used.
2) Two input files in the "Threshold_set" subfolder with adjustable parameters for the output file:
       i) Pident_Plength.txt is used to identify the contigs located in nuclear exon regions. The parameters of “Pident” and “Plength” are percentage of identical matches and alignment length, respectively. The default settings are 75% and 99%.   
     ii) Missing_threshold.txt is used to remove the loci having a level of missing observations or higher; normally 10-20%. The default setting is 0%. (Optional)
3) Protein database of 38 plant species compressed by tarball in the folder “Input_data” are used. 
 
Output files:
1) Nu_contigs.fasta consists of de novo assembly contigs from all samples as a reference for nuclear SNP genotyping.
2) Nu_SNP_genotypes.txt includes nuclear SNP genotype data after removing SNPs showing the same genotypes for all samples and residing within 20 bases from both ends of each contig.
3) Nu_clean_SNP_genotypes.txt includes nuclear SNP genotype data after removing SNPs with missing based on Nu_SNP_genotypes.txt. 
4) Nu_SNP_hap.txt is unphased haplotype data corresponding to Nu_SNP_Genotypes.txt.
5) Nu_clean_SNP_hap.txt includes the haplotype data after removing SNPs with missing based on Nu_SNP_hap.txt. 
6) NE_contigs.fasta consists of de novo assembly contigs in nuclear exon regions from all samples as a reference for SNP genotyping in exon regions.
7) NE_contigs_information.txt consists of proten information associated with the contigs in nuclear exon regions.
8) NE_SNP_genotypes.txt includes SNP genotype data in exon regions after removing SNPs showing the same genotypes for all samples and residing within 20 bases from both ends of each contig.
9) NE_clean_SNP_genotypes.txt includes SNP genotype data after removing SNPs with missing based on NE_SNP_genotypes.txt.  
10) NE_SNP_hap.txt is unphased haplotype data corresponding to NE_SNP_Genotypes.txt.
11) NE_clean_SNP_hap.txt includes haplotype data after removing SNPs missing based on NE_SNP_hap.txt.  
12) Cp_SNPs.txt includes SNP data in chloroplast.
13) Cp_clean_SNPs.txt includes SNP data after removing SNPs with missing based on Cp_SNPs.txt.
14) Mt_SNPs.txt includes SNP data in mitochondria.
15) Mt_clean_SNPs.txt includes SNP data after removing SNPs with missing based on Mt_SNPs.txt.

 

