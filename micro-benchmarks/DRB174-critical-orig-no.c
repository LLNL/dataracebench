/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * FT.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 FT suit.
 * Intel Inspector can not correctly analyze the nowaite, and report a false postive.
 * Tsan can not correctly analyze the critical, and report a false postive.
*/

#include <stdio.h>

int main(int argh, char* argv[]){
  int i;
  double q[10], qq[10];

  #pragma omp parallel for default(shared) private(i)
  for (i = 0; i < 10; i++) qq[i] = 1.0;
  /*initial m */
  #pragma omp parallel default(shared) 
  {
    #pragma omp for nowait //intel
      for (i = 0; i <= 10 - 1; i++) q[i] += qq[i];
    #pragma omp critical //tsan
      {
          q[i] += 1.0;
      }
    #pragma omp barrier
    #pragma omp single
     {
        q[i] += 1.0;
     }

  }
  return 0;
}
