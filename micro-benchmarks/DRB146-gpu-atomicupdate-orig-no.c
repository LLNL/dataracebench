/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The var@25:5 is atomic update. Hence, there is no data race pair.
*/

#include <stdio.h>
#include <omp.h>
#define N 100

int var = 0;

int main(){
  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute
  for (int i=0; i<N; i++){
    #pragma omp atomic update
    var++;
  }
  printf("%d\n ",var);
  return 0;
}
