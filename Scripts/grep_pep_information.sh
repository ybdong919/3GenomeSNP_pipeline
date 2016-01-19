#!/bin/bash

IFS=$'\n' id=($(cat associated_subject_id.txt))
for x in ${id[*]}
do
   for y in *.title
   do
      k=$(grep "^>$x" $y)
      if [ "$k" ]
      then
          echo -e "$y\t$k" >> associated_pep_titles.txt
          break
      fi
   done   
done
rm *.title