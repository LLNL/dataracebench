/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The increment operation at line@27:7 is atomic but the condition check at line@25:8 is not.
Data Race Pair, var@27:7 and var@27:7.
*/

#include <stdio.h>
#include <omp.h>
#define N 100

int var = 0;

int main(){
  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<N*2; i++){
    if(var<N){
      #pragma omp atomic
      var++;
    }
  }

  printf("%d\n",var);
  return 0;
}
