#!/usr/bin/perl -w
use strict;

my $qfile="./reads_aligned_to_genome";
opendir QFILE, $qfile or die "can not open dir";
foreach my $onename (readdir QFILE){
   next if $onename =~/^\./;
   print $onename."\n";
   my $wholename=$qfile."/".$onename;
   open (CONTENT,'<',$wholename) or die;
   my @content=<CONTENT>;
   my @fasta= &fastQtoA (@content);
   
   $onename=~ s/txt$/fasta/;
    
   open (OUTPUT,'>',$onename) or die;
   foreach (@fasta){
      chomp $_;
      print OUTPUT $_."\n"; 
      
   }
   close OUTPUT;
   close CONTENT;
}
closedir QFILE;




######################subroutine###############################
sub fastQtoA {
   my @array=@_;
   my %hash;
   my $i=0;
   foreach (@array){
      chomp $_;
      $i +=1;
      if (/^\+$/){
         my $title=$array[$i-3];
         $title=~s/^@/>/;
         my $sequ=$array[$i-2];
         $hash{$title}=$sequ;

      }


   }

   %hash;

}
