/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
This kernel is modifie version from “DataRaceOnAccelerator A Micro-benchmark Suite for Evaluating
Correctness Tools Targeting Accelerators” by Adrian Schmitz et al.
Due to distribute parallel for simd directive at line 31, there is a data race at line 33.
Data Rae Pairs, var@33:5:W vs. var@33:12:R
.*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#define N 100
#define C 16

int main(){
  int var[N];

  for(int i=0; i<N; i++){
    var[i]=0;
  }

  #pragma omp target map(tofrom:var[0:N]) device(0)
  #pragma omp teams distribute parallel for simd safelen(C)
  for (int i=C; i<N; i++){
    var[i]=var[i-C]+1;
  }

  printf("%d\n",var[97]);

  return 0;
}
