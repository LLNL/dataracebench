#!/bin/sh
## create_pped_version.sh for  in /Users/pouchet
##
## Made by Louis-Noel Pouchet
## Contact: <pouchet@cse.ohio-state.edu>
##
## Started on  Mon Oct 31 16:20:01 2011 Louis-Noel Pouchet
## Last update Mon Oct 31 20:42:35 2011 Louis-Noel Pouchet
##

if [ $# -lt 1 ]; then
    echo "Usage: create_pped_version.sh <file.F90> [gcc -E flags]";
    exit 1;
fi;
args="$2";
file="$1";
head -n 8 $file | sed 's/F90/f90/' > .__poly_top.f;
tail -n +9 $file > .__poly_bottom.F;
filename=`echo "$file" | sed -e "s/\(.*\).F90/\1/1"`;
filenameorig=`basename $file`;
benchdir=`dirname "$file"`;
gcc -E .__poly_bottom.F -I$benchdir $args 2>/dev/null > .__tmp_poly.f
#echo "gcc -E .__poly_bottom.f -I$benchdir -Iutilities $args 2>/tmp/moh > .__tmp_poly.f"
sed -e "/^[ ]*$/d" .__tmp_poly.f | sed -e '/^#/d' | sed -e "s~.__poly_bottom.f~$filenameorig~g" > .__poly_bottom.f;
cat .__poly_top.f > $filename.preproc.f90;
#echo "#include <polybench.h>\n" >> $filename.preproc.c;
cat .__poly_bottom.f >> $filename.preproc.f90;
rm -f .__tmp_poly.f .__poly_bottom.f .__poly_top.f .__poly_bottom.F ;

