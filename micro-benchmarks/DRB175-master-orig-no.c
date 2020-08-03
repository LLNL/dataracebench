/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * IS.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 IS suit.
 * Intel Inspector can not correctly analyze the master, and report a false positive.
*/

#include <stdio.h>

int main(int argh, char* argv[]){
  int i,j;
  int q[10], qq[10];
  
  #pragma omp parallel private(i)
    for( i=0; i<10; i++){
      #pragma omp master /*intel*/
      {
        q[i] = i;
        for (j=0; j<10;j++)
        qq[j] = q[j];
      }
    }
    return 0;
}
