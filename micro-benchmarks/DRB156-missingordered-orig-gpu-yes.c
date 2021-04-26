/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*This example is referred from DRACC by Adrian Schmitz et al.
Missing ordered directive causes data race pairs var@28:5:W vs. var@28:13:R
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#define N 100

int main(){
  int var[N];
  for(int i=0; i<N; i++){
    var[i]=0;
  }

  #pragma omp target map(tofrom:var[0:N]) device(0)
  #pragma omp teams distribute parallel for
  for (int i=1; i<N; i++){
    var[i]=var[i-1]+1;
  }

  for(int i=0; i<N; i++){
    if(var[i]!=i){
      printf("Data Race Present\n");
      return 0;
    }
  }
  return 0;
}
