#!/usr/bin/perl -w


### Identify contigs in exon regions: Step1, identify the contig's names in exon regions; Step2, identify the sequences of these contigs and then output them in FASTA format.###

############################## Step1 ##########################################################################################################

my $blares="blastresults.txt";          
open (BLRE,'<', $blares) or die;
my @blares=<BLRE>;
my @dele_result;
my $i=1;
my @firstline=split /,/,$blares[0];
$dele_result[0]=$blares[0];
my $standard=$firstline[0];
#print $standard;
foreach my $line (@blares){               #delete duplicated lines if their 'qseqid' values are same.
     #print "$line\n";
     my @cells=split/,/,$line;
     #print "$cells[0]";
     if ($cells[0] ne $standard){
        $standard=$cells[0];
        $dele_result[$i]=$line;
        $i +=1;
     }
}
       
open (THREIDENT,'<',"Threshold_set/Pident_Plength.txt")or die "Pident DIE";  #input threshold values of p-length and pident
my @pident_thres=<THREIDENT>;
chomp $pident_thres[1];
chomp $pident_thres[3];
my $pident_threshold=$pident_thres[1];
my $plength_threshold=$pident_thres[3];

my @contig_names;                        # select the 'qseqid'values in each line with 'pident'>= pident_threshold and 'p-length'>= plength_threshold.
my @subject_id;                       # select associated subject seq-id (sseqid).
my $j=0;
foreach my $line (@dele_result){
     #print "$line\n";
     my @cells=split/,/,$line;
     my @query=split/__/,$cells[0];
     my $que_length=$query[2];
     my $align_length= $cells[3]*3;
     my $p_length=($align_length/$que_length)*100;
     if ($p_length >=$plength_threshold && $cells[2]>=$pident_threshold){
         $contig_names[$j]=$cells[0];
         $subject_id[$j]=$cells[1];
         $j +=1;
         #print "$contig_names[$j]\n";
     }
}
#my $qqq=@contig_names;
#print "$qqq\n";

############################ Step2: Select contigs belonging to exon regions from all of contigs (allcontigs.fa) ################################

my $contig="allcontigs.fa";
open (CONTIG,'<',$contig)or die;
my @contig=<CONTIG>;
#print $contig[3];

my $num=@contig;
my %hash;
for (my $i=0;$i<$num;$i+=2){
    chomp $contig[$i];
    chomp $contig[$i+1];
    $hash{$contig[$i]}=$contig[$i+1];
    #print $contig[$i];
}
my %exoncontig;
foreach my $name (@contig_names){
     chomp $name;
     #print $name;
     my $title=">".$name." ";
     #print $title;
     if ($hash{$title}){
        $exoncontig{$title}=$hash{$title};      
     }

}

open(OUTPUT,'>', 'exoncontigs.fa') or die;      # output the exon contigs file in FASTA.
my $k;
my $v;
while (($k,$v)= each %exoncontig) {       
    print OUTPUT "$k\n$v\n";
}
close OUTPUT;
close CONTIG;

############################## Step3: Extract protein information associated with exon-contigs #######################################################

my $out_proinf="./Output_results/NE_contigs_information.txt";
open (OUTINF,'>', $out_proinf)or die;
print OUTINF "Exon-contigs\tSpeciesDatabase\tProtein information\n";

open (OUTTITLE,'>',"associated_subject_id.txt")or die;  
foreach (@subject_id){
   chomp $_;
   print OUTTITLE "$_\n";
}

system("/bin/bash ./Scripts/grep_pep_information.sh");

open (INTIL,'<',"associated_pep_titles.txt")or die "intil";
my @intil=<INTIL>;
my $numtil=@intil;
for (my $x=0;$x<$numtil;$x++){
    chomp $contig_names[$x];
    chomp $intil[$x];
    my $fix=substr($intil[$x],1);
    print OUTINF "$contig_names[$x]\t$fix\n";
}

close OUTTITLE;
close INTIL;
close OUTINF;