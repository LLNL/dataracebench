/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
At line 21, the teams distribute parallel for directive without the reduction clause will lead to
intra-region data race. Data Race Pair, var@24:5 and var@24:5.
*/

#include <stdio.h>
#define N 100

int main(){
  int var = 0;

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<N; i++){
    var++;
  }

  printf("%d\n ",var);
  return 0;
}
