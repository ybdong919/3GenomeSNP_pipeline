#!/usr/bin/perl -w
#$ -S /usr/bin/perl
#$ -N perl_findGT
#$ -j y
#$ -cwd
#$ -R y
use strict;

############################# step1 find GT in all examples ####################################################################

open(CONTIGS,'<','align_contigs') or die;
my @contigs = <CONTIGS>;
close CONTIGS;

my %list;
foreach (@contigs){
    chomp $_;
    if (/(.+\d+)\t(\w+)/) {
        $list{$1} = $2;
    }    
}


##############################################################

open(STEP1,'<', 'names_of_step4') or die;
my @namefile_step1 = <STEP1>;
#print @namefile_step1;
close STEP1;

my @list =keys %list;

foreach (@namefile_step1){
    chomp $_;
    open(FILE,'<', $_) or die;
    my @input =<FILE>;
    close FILE;
    
    my %data;
    foreach (@input){
      chomp $_;
      if (/^(.+\t\d+)\t(.+)/) {
         my $keys = $1;
        $data{$keys}=$2; 
      }  
    }

    foreach (@list){
        chomp $_;
        my $var = $data{$_};
        if (defined($var)) {
            $list{$_} .= "\t".$data{$_};
        }else {
            $list{$_} .="\tNA\t0";
        }
    } 
}


###################################### delete Quality columns ####################
######################################  ################
my @k2 = keys %list;
foreach (@k2){
    my @line = split /\t/, $list{$_};
    #print $line[2]."\n";
    my $stri;
    foreach (@line){
        if (/^[^0-9]/){
          $stri .= "$_\t"; 
        }    
    }
    $list{$_} = $stri;   
    #print $stri."\n";
    #print $av_qt."\n";
}

##############################################################################################
#########################################   delete consensus sites###################

my $j = @namefile_step1;
my @k = keys %list;
   
foreach (@k){
     my @line = split /\t/, $list{$_};
     my $con;
     
     shift @line;
     foreach (@line){
        if ($_ ne 'NA') {
            $con = $_;
            last;
        }        
     }
     #print @line;
     #print "\n";
     my $num =0;
     foreach (@line){
        if ($_ eq $con || $_ eq "NA") {
            $num += 1;
        }   
     }
     if ($num == $j) {
        delete $list{$_};
     }   
}

###############################################################
my @titles;
my $x = 0;
foreach (@namefile_step1){
    if (/step4_(.+S\d+)/) {
        $titles[$x] = $1;
        $x += 1;
    }
}

open(OUTPUT,'>', 'All_GTs.txt') or die;

print OUTPUT "CHROM\tPOS\tREF\t";
foreach (@titles){
    print OUTPUT "$_\t";    
}
print OUTPUT "\n";
my $k;
my $v;
while (($k,$v)= each %list) {      
    print OUTPUT "$k\t$v\n";
}
close OUTPUT;

############################# step2 sort GT ####################################################################

my $input_gt = "All_GTs.txt";
open(INPUTGT,'<', $input_gt) or die;
my @inputgt = <INPUTGT>;
my $title_gt = $inputgt[0];
chomp $title_gt;
shift @inputgt;

my %sorthash;
foreach (@inputgt){
    if (/(\d+)__len__\d+\t(\d+)\t.+/) {       
        $sorthash{$1}{$2}=$_;             #definate a multi-dimension hash
    }       
}

my $i=0;
my @value;
foreach my $key1 (sort {$a<=>$b} keys %sorthash){                         # using Multi-dimension hash for sorting 
    foreach my $key2 (sort {$a <=> $b} keys %{$sorthash{$key1}}){
        $value[$i]=$sorthash{$key1}{$key2};
        $i +=1;
    }
}

open(OUTPUTGT,'>',"All_SNP_Genotypes.txt") or die;
print OUTPUTGT $title_gt;
print OUTPUTGT "\n";
foreach (@value){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;

############################# step3 remove duplicated GT-data and missing GT-data ####################################################################

open(THRESHOLD,'<',"Threshold_set/Missing_threshold.txt") or die;
my @miss_thres =<THRESHOLD>;
chomp $miss_thres[1];
my $miss_threshold = $miss_thres[1];
#print $miss_threshold;

my $input_gt1 = "All_SNP_Genotypes.txt";
open(INPUTGT,'<', $input_gt1) or die;
my @inputgt1 = <INPUTGT>;
my $title_gt1 = $inputgt1[0];
chomp $title_gt1;
shift @inputgt1;

my %del_dup;
foreach (@inputgt1){
    if (/(.+\d+\t\d+)\t(.+)/) {
        $del_dup{$2}=$1;
    }   
}

my @keys = keys %del_dup;
foreach (@keys){
    chomp $_;
    my @splits_keys = split /\t/,$_;
    my $mis_num =0;
    foreach my $unit(@splits_keys){      
        if ($unit eq "NA") {
            $mis_num +=1;
        }          
    }
    if ($mis_num > $miss_threshold) {
        delete $del_dup{$_};    
        }
}

open(OUTPUTGT,'>',"GT_data_without_duplication.txt") or die;
print OUTPUTGT $title_gt1;
print OUTPUTGT "\n";
my $k1;
my $v1;
while (($k1,$v1) = each %del_dup) {
    print OUTPUTGT "$v1\t$k1\n";
}
close INPUTGT;
close OUTPUTGT;
close THRESHOLD;

############################# step4 remove GT-data if SNP position <=20 ############################################

#open(THRESHOLD,'<',"Threshold_set/SNP_position_threshold.txt") or die;
#my @SNP_thres =<THRESHOLD>;
#chomp $SNP_thres[1];
#my $SNP_threshold = $SNP_thres[1];
#print $SNP_threshold;

my $input_gt2 = "GT_data_without_duplication.txt";
open(INPUTGT,'<', $input_gt2) or die;
my @inputgt2 = <INPUTGT>;
my $title_gt2 = $inputgt2[0];
chomp $title_gt2;
shift @inputgt2;

my %mulhash;
my %outhash;
foreach (@inputgt2){
    if (/(\d+)__len__(\d+)\t(\d+)\t.+/) {       
        $mulhash{$1}{$3}=$2;             #definate a multi-dimension hash
        $outhash{$1}{$3}=$_;
    }       
}

my $ib=0;
my @value1;
foreach my $key1 (sort {$a<=>$b} keys %mulhash){               # using Multi-dimension hash for sorting and delete SNPs located at both ends of each contig
    
    foreach my $key2 (sort {$a <=> $b} keys %{$mulhash{$key1}}){
        
            if (($key2 > 20)&&($key2 < ($mulhash{$key1}{$key2} - 20))) {
                 $value1[$ib]=$outhash{$key1}{$key2};
                 $ib +=1;
            }            
    }
}

open(OUTPUTGT,'>',"Clean_SNP_Genotypes.txt") or die;
print OUTPUTGT $title_gt2;
print OUTPUTGT "\n";
foreach (@value1){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;
close THRESHOLD;

############################# step5 Calling SNP haplotype ############################################

######################### make a file of sample-names
open(SAMNAM,'<', "names_of_step4") or die;
my @samnam =<SAMNAM>;

for (@samnam){
    chomp $_;
    if (/^(step4_)(.+)/) {
        $_=$2;
    }
}
my $samnam_num = @samnam;
my $panum=0;
my @samnam_part;
for (@samnam){
    if (/^(.+S\d+).+/) {
        $samnam_part[$panum]=$1;
        #print $samnam_part[$panum]."\n";
        $panum +=1;
    }    
}

close SAMNAM;

######################### calling a sub_program for transposing the data between row and column
######################### make SNP halotype corresonding with Genotype

my @inputfiles = ("All_SNP_Genotypes.txt","Clean_SNP_Genotypes.txt");
my @outputfiles = ("All_SNP_hap.txt","Clean_SNP_hap.txt");
my $xnew=0;
foreach (@inputfiles){
    chomp $_;
    my $dire= $_;
    &transpose ($dire);                                      ###  calling a sub_program for transposing
    
    open(HAINPUT,'<', "transposed_data.txt") or die;        ### make SNP halotype corresonding with Genotype  
    my @samples =<HAINPUT>;

    chomp $samples[0];
    chomp $samples[1];
    my @locus= split /\t/, $samples[0];
    my @pos= split /\t/, $samples[1];
    my $tit_loc = join "\t", @locus;
    my $tit_pos = join "\t", @pos;

    chomp $samples[2];
    my @refe= split /\t/, $samples[2];
    my $reftit_fir= $refe[0];
    shift @refe;
    foreach (@refe){
        my @ref_cel= split //,$_;
        $_ = $ref_cel[0];
    }
    my $reftit_sec= join "\t", @refe;
    my $tit_ref =$reftit_fir."\t".$reftit_sec;

    my %sam_hash;
    splice @samples,0,3;
    for (@samples){
        chomp $_;
        if (/^(.+S\d+)\t(.+)/) {
            $sam_hash{$1}=$2;
        }    
    }

    my @sam_keys = keys %sam_hash;

    foreach my $x_samp(@sam_keys){
        my %vcf_hash;
        chomp $x_samp;
    
        for (my $i=0; $i < $samnam_num; $i++){
            chomp $samnam_part[$i];
            if ($samnam_part[$i] eq $x_samp) {
                chomp $samnam[$i];
                open(SAMPLE,'<',$samnam[$i] ) or die;
                my @vcf =<SAMPLE>;
                #print @vcf;
                foreach (@vcf){
                    if (/^(.+\d+)\t(\d+)\t(\.)\t(.+)\tDP/) {
                        my $first=$1."_".$2;
                        my @second= split /\t/, $4;
                        shift @second;
                        my $sec = shift @second;
                        #print $sec."\n";
                        if ($sec =~ /[A-Z]/) {
                            $vcf_hash{$first}=$sec;
                        }
                        if ($sec =~ /,/) {
                            my @dou = split /,/, $sec;
                            $vcf_hash{$first}=$dou[0];
                        }
                    
                    }
                 
                }
                close SAMPLE;
            }   
        }
    
        my @samp_line= split /\t/, $sam_hash{$x_samp};
        my $column=0;
        for (@samp_line){
            $column += 1;
            chomp $_;
            if (/NA/) {
                $_="00";
            }
            
            my @cell = split //, $_;
            chomp $cell[0];
            my $alp_num=@cell;
        
            my $shouldbe;
            for (my $i=0; $i < $alp_num; $i++){
                $shouldbe .= $cell[0];
            }
        
            if ($_ eq $shouldbe) {
                $_=$cell[0];
            }else {
                chomp $locus[$column];
                chomp $pos[$column];
                my $site =$locus[$column]."_".$pos[$column];
                #print $site;
                $_=$vcf_hash{$site};               
            }       
        }
        my $new_line = join "\t",@samp_line;
        $sam_hash{$x_samp}=$new_line;
    }

    open(HAP,'>', "pre_Clean_SNP_hap.txt") or die;
    print HAP "$tit_loc\n";
    print HAP "$tit_pos\n";
    print HAP "$tit_ref\n";

    my $hk;
    my $hv;
    while (($hk,$hv)= each %sam_hash) {      
        print HAP "$hk\t$hv\n";
    }
    close HAP;
    close HAINPUT;

    my $direx= "pre_Clean_SNP_hap.txt";                     ###calling the sub_program of transposing again
    &transpose ($direx);
    my $oldnam="transposed_data.txt";

    rename $oldnam => $outputfiles[$xnew];
    $xnew +=1;
}

##################################################################################################################################################################
###############           A sub_program for transpose between row and column          ########################################################################
###############                                                                     #######################################################################  
###################################################################################################################################################################

sub transpose {
    
    open(TRANSPOSE,'>', "transposed_data.txt") or die;
    open(DATA,'<', $_[0] ) or die;
    my @data =<DATA>;
    foreach (@data){
        $_ =~s/\s+$//g;
    }
    my $old_rows = @data;

    my @for_columns = split /\t/, $data[0];
    my $old_columns = @for_columns;
    #print "$old_columns,$old_rows";
    my $wholestring;
    foreach (@data){
        chomp $_; 
        $wholestring .= $_."\t"; 
    }

    #   print $wholestring;
    my @all_cells = split /\t/, $wholestring;
    my $ax=@all_cells;
    #print $a;
    my @sheet;
    for (my $il=0; $il<$old_columns; $il++){
        for (my $nl=$il; $nl<$ax; $nl += $old_columns){
            $sheet[$il].= $all_cells[$nl]."\t";     
        }   
    }

    foreach (@sheet){
        print TRANSPOSE "$_\n";
    
    }
    close TRANSPOSE;
    close DATA;        
}






