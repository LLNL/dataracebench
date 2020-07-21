/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
By utilizing the ordered construct @29 the execution will be
sequentially consistent. No Data Race Pair.
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
    #pragma omp parallel for ordered
    for (int i=1; i<N; i++){
      #pragma omp ordered
      {
        var[i]=var[i-1]+1;
      }
    }

  for(int i=0; i<N; i++){
    if(var[i]!=i){
      printf("Data Race Present");
      return 0;
    }
  }

  return 0;
}
