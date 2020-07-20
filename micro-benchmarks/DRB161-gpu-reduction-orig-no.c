/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
At line 21, the teams distribute parallel for directive with the reduction clause will avoid
intra-region data race. No data race pair.
*/

#include <stdio.h>
#define N 100

int main(){
  int var = 0;

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for reduction(+:var)
  for (int i=0; i<N; i++){
    var++;
  }

  printf("%d\n ",var);
  return 0;
}
