/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
This kernel is referred from “DataRaceOnAccelerator A Micro-benchmark Suite for Evaluating
Correctness Tools Targeting Accelerators” by Adrian Schmitz et al.
Concurrent access of var@35:7 without acquiring locks causes atomicity violation. Data race present.
Data Race Pairs, var@35:7:W vs. var@35:7:W
*/

#include <stdio.h>
#include <omp.h>
#define N 100
#define C 64

int main(){

  int var[C];

  for(int i=0; i<C; i++){
    var[i]=0;
  }

  #pragma omp target map(tofrom:var[0:C]) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<N; i++){
    #pragma omp simd
    for(int i=0; i<C; i++){
      var[i]++;
    }
  }

  printf("%d\n",var[63]);

  return 0;
}
