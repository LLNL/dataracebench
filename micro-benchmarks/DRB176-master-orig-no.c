/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * SP.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 SP suit.
 * Intel Inspector can not correctly analyze the master, and report a false postive.
 * Tsan can not correctly analyze the barrier, and report a false postive.
*/

#include <stdio.h>

int main(int argh, char* argv[]){
  int i,j;
  int qq[10];
  
  #pragma omp parallel private(i)
    for( i=0; i<10; i++){
        #pragma omp barrier /*Tsan*/
          for (j=0; j<10;j++) qq[j] = 0;
    }
   return 0;
}
