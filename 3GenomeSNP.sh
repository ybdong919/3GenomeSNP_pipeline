#!/bin/bash

sta=$(date)
./Scripts/separate_reads.sh                                     ##### generate unique Nu, Cp and Mt reads
tar -jxv -f ./Input_data/Pep_database.tar.bz2 -C ./             ##### 1) generate Nu,NE contigs. 2)identify Nu, NE SNPs  
mv ./Nu_unique_reads/CpMtuncontam* ./
./Scripts/generate_nuclear_contigs.sh
./Scripts/generate_exon_contigs.sh
./Scripts/call_exon_SNP.sh                        
./Scripts/call_nuclear_SNP.sh            
rm allcontigs.fa exoncontigs.fa
echo "Calling Nu, NE SNPs is finished"
mv ./CpMtuncontam* ./Nu_unique_reads/
rm -r Pep_database

./Scripts/call_CpMt_SNP.sh                                 ##### generate Cp, Mt SNPs 
rm -r *unique_reads 
fin=$(date)
echo -e "3GenomeSNP running is over.\nStart time is $sta.\nFinish time is $fin."
