/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
Concurrent access on same variable var@29 and var@32 leads to the race condition if two different
locks are used. This is the reason here we have used the atomic directive to ensure that addition
and subtraction are not interleaved. No data race pairs.
*/

#include <omp.h>
#include <stdio.h>

#define N 100

int var = 0;

int main(){

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for(int i=0; i<N; i++){
    #pragma omp atomic
    var++;

    #pragma omp atomic
    var -= 2;
  }

  printf("%d\n",var);
  return 0;
}
