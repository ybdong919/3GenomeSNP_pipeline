#!/usr/bin/perl -w
use strict;


open(CONTIGS,'<','SNP_align_contigs') or die;
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

open(STEP1,'<', 'SNP_names_of_step4') or die;
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


###################################### delete QTL columns ####################
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
#########################################   delete consensus sites  ###################


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

#############################################################################################
my @titles;
my $x = 0;
foreach (@namefile_step1){
    if (/step4_(.+S\d+)/) {
        $titles[$x] = $1;
        $x += 1;
    }
}



open(OUTPUT,'>', 'All_SNPs.txt') or die;

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




############################## to sort SNP data################################
my $input_gt = "All_SNPs.txt";
open(INPUTGT,'<', $input_gt) or die;
my @inputgt = <INPUTGT>;
my $title_gt = $inputgt[0];
chomp $title_gt;
shift @inputgt;

my %sorthash;
foreach (@inputgt){
    if (/.+\t(\d+)\t.+/) {       
        $sorthash{$1}=$_;             
    }       
}

my $i=0;
my @value;
foreach my $key (sort {$a<=>$b} keys %sorthash){                         # using hash for sorting 
    
        $value[$i]=$sorthash{$key};
        $i +=1;
   
}

open(OUTPUTGT,'>',"sorted_All_SNPs.txt") or die;
print OUTPUTGT $title_gt;
print OUTPUTGT "\n";
foreach (@value){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;

#######################################################################################
################### remove SNPs with missing ##########################################


open(THRESHOLD,'<',"Threshold_set/Missing_threshold.txt") or die;
my @miss_thres =<THRESHOLD>;
chomp $miss_thres[1];
my $miss_threshold = $miss_thres[1];
#print $miss_threshold;

my $input_gt1 = "sorted_All_SNPs.txt";
open(INPUTGT,'<', $input_gt1) or die;
my @inputgt1 = <INPUTGT>;
my $title_gt1 = $inputgt1[0];
chomp $title_gt1;
shift @inputgt1;

my %del_miss;
foreach (@inputgt1){
    if (/(.+\t\d+)\t(.+)/) {
        $del_miss{$1}=$2;
    }   
}

my @keys = keys %del_miss;
foreach (@keys){
    chomp $del_miss{$_};
    my @splits_keys = split /\t/,$del_miss{$_};
    my $mis_num =0;
    foreach my $unit(@splits_keys){      
        if ($unit eq "NA") {
            $mis_num +=1;
        }          
    }
    if ($mis_num > $miss_threshold) {
        delete $del_miss{$_};    
        }
}

open(OUTPUTGT,'>',"SNP_data_without_verthreshold_missing.txt") or die;
print OUTPUTGT $title_gt1;
print OUTPUTGT "\n";
my $k1;
my $v1;
while (($k1,$v1) = each %del_miss) {
    print OUTPUTGT "$k1\t$v1\n";
}
close INPUTGT;
close OUTPUTGT;
close THRESHOLD;

####################################

############################## to sort SNP data################################
my $input_gt2 = "SNP_data_without_verthreshold_missing.txt";
open(INPUTGT,'<', $input_gt2) or die;
my @inputgt2 = <INPUTGT>;
my $title_gt2 = $inputgt2[0];
chomp $title_gt2;
shift @inputgt2;

my %sorthash1;
foreach (@inputgt2){
    if (/.+\t(\d+)\t.+/) {       
        $sorthash1{$1}=$_;             
    }       
}

my $i1=0;
my @value1;
foreach my $key (sort {$a<=>$b} keys %sorthash1){                         # using hash for sorting 
    
        $value1[$i1]=$sorthash1{$key};
        $i1 +=1;
   
}

open(OUTPUTGT,'>',"Clean_SNPs.txt") or die;
print OUTPUTGT $title_gt2;
print OUTPUTGT "\n";
foreach (@value1){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;









