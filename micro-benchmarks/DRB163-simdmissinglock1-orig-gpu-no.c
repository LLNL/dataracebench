/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Concurrent access of var@31:7 has no atomicity violation. No data race present.
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
  #pragma omp teams distribute parallel for reduction(+:var) 
  for (int i=0; i<N; i++){
    #pragma omp simd
    for(int i=0; i<C; i++){
      var[i]++;
    }
  }

  for(int i=0; i<C; i++){
    if(var[i]!=100){
      printf("%d\n",var[i]);
    }
  }

  return 0;
}
