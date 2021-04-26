/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/* 
This example is from DRACC by Adrian Schmitz et al.
Concurrent access on a counter with no lock with simd. Atomicity Violation. Intra Region.
Data Race Pairs: var@33:7:W vs. var@33:7:W
*/

#include <stdio.h>
#define N 20
#define C 8

int main(){
  int var[C];

  for(int i=0; i<C; i++){
    var[i] = 0;
  }

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams num_teams(1) thread_limit(1048) 
  #pragma omp distribute parallel for 
  for (int i=0; i<N; i++){
    #pragma omp simd
    for(int i=0; i<C; i++){
      var[i]++;
    }
  }

  for(int i=0; i<C; i++){
    if(var[i]!=N) printf("%d\n ",var[i]);
  }

  return 0;
}
