/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The increment at line number 26 is critical for the variable
var@26:5. Therefore, there is a possible Data Race pair var@26:5:W vs. var@26:5:W
*/

#include <stdio.h>
#include <omp.h>
#define N 100

int var = 0;

int main(){
  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for(int i=0; i<N*2; i++){
    #pragma omp critical
    var++;
  }

  printf("%d\n ",var);

  return 0;
}
