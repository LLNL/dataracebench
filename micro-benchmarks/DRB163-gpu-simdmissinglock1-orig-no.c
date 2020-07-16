/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Concurrent access of var@35:7 enclosed in critical section ensures no atomicity violation. No data race present.
*/

#include <stdio.h>
#include <omp.h>
#define N 100
#define C 64

int main(){
  omp_lock_t lck;
  int var[C];
  omp_init_lock(&lck);

  for(int i=0; i<C; i++){
    var[i]=0;
  }

  #pragma omp target map(tofrom:var[0:C]) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<N; i++){
    #pragma omp critical
    #pragma omp simd
    for(int i=0; i<C; i++){
      omp_set_lock(&lck);
      var[i]++;
      omp_unset_lock(&lck);
    }
  }

  for(int i=0; i<C; i++){
    if(var[i]!=100){
      printf("%d\n",var[i]);
    }
  }

  return 0;
}
