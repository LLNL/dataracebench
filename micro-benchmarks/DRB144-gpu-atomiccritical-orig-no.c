/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The condition check at line 26:8 is critical and increment at line number 28 is atomic for the variable
var@28:7. Therefore, there are no data race pairs.
*/

#include <stdio.h>
#include <omp.h>
#define N 100

int var = 0;

int main(){
  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<N*2; i++){
    #pragma omp critical
    if(var<N){
      #pragma omp atomic
      var++;
    }
  }
  printf("%d\n ",var);

  return 0;
}
