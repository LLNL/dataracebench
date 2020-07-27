/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The increment operation at line@27:7 is team specific as each team work on their individual var.
No Data Race Pair
*/

#include <stdio.h>
#include <omp.h>
#define N 100

int var = 0;

int main(){
  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for reduction(+:var)
  for (int i=0; i<N; i++){
    var++;
  }

  printf("%d\n",var);
  return 0;
}
