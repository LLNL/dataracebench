#!/bin/bash
# Copyright (c) 2017, Lawrence Livermore National Security, LLC.
# Produced at the Lawrence Livermore National Laboratory
# Written by Chunhua Liao, Pei-Hung Lin, Joshua Asplund,
# Markus Schordan, and Ian Karlin
# (email: liao6@llnl.gov, lin32@llnl.gov, asplund1@llnl.gov,
# schordan1@llnl.gov, karlin1@llnl.gov)
# LLNL-CODE-732144
# All rights reserved.
#
# This file is part of DataRaceBench. For details, see
# https://github.com/LLNL/dataracebench. Please also see the LICENSE file
# for our additional BSD notice
#
# Redistribution of Backstroke and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the disclaimer below.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the disclaimer (as noted below)
#   in the documentation and/or other materials provided with the
#   distribution.
#
# * Neither the name of the LLNS/LLNL nor the names of its contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL LAWRENCE LIVERMORE NATIONAL
# SECURITY, LLC, THE U.S. DEPARTMENT OF ENERGY OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

#----------------------------------------------------------------
# copy& paste the two tables in https://github.com/LLNL/dataracebench/blob/master/README.md
# save to a benchmark_list.txt file
# then run thisScript benchmark_list.txt to count Y and N labels.
#example output:
# ./count_drb_labels.sh benchmark_list.txt
# ----1: Y1, N1-----
# 26
# 14
# ----2: Y2, N2-----
# 17
# 19
# ----3: Y3, N3-----
# 8
# 9
# ----4: Y4, N4-----
# 3
# 4
# ----5: Y5, N5-----
# 1
# 2
# ----6: Y6, N6-----
# 4
# 7
# ----7: Y7, N7-----
# 4
# 9
# Total Y label count=63
# Total N label count=64
##----------------------------------------------------------------
set -u

# expect an argument for the text file storing benchmarks and labels
# $# means the number of arguments passed to a function, or to the script itself
if [ $# -eq 1 ]; then
  INPUT_FILE=$1
else
  echo This script needs one argument while there is $# arguments.
  echo Usage:$0 inputfile
  echo Exampe:$0 benchmark_list.txt
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: cannot find $INPUT_FILE. Please make sure it exists!"
  exit 1
fi

ysum=0
nsum=0

for var in 1 2 3 4 5 6 7; do
  YLABEL="Y$var"
  NLABEL="N$var"

echo "----$var: $YLABEL, $NLABEL-----"
  ycount=`grep $YLABEL $INPUT_FILE | wc | awk '{print $1}'`
  echo $ycount
  let "ysum+=$ycount"
  ncount=`grep $NLABEL $INPUT_FILE | wc | awk '{print $1}'`
  echo $ncount
  let "nsum+=$ncount"
done

echo "Total Y label count=$ysum"
echo "Total N label count=$nsum"
