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
 * Intel Inspector can not correctly analysis the master, and report a false postive.
 * Tsan can not correctly analysis the barrier, and report a false postive.
*/

#include <stdio.h>

int main(int argh, char* argv[]){
  int i,j;
  int q[10], qq[10],qqq[10];
  
  #pragma omp parallel private(i)
    for( i=0; i<10; i++){
      #pragma omp master /*intel*/
      {
        q[i] = i;
        for (j=0; j<10;j++)
        qq[j] = q[j];
      }
      #pragma omp barrier /*Tsan*/
        for (j=0; j<10;j++) qq[j] = 0;
      #pragma omp for nowait
        for (j=0; j<10;j++) qqq[j] = q[j];
    }
    return 0;
}
