/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
This example is referred from DataRaceOnAccelerator : A Micro-benchmark Suite for Evaluating
Correctness Tools Targeting Accelerators.
Though we have used critical directive to ensure that addition and subtraction are not overlapped,
due to different locks addlock@30:26 and sublock@33:26 interleave each others operation.
Data Race pairs, var@31:5:W vs. var@34:5:W
*/

#include <omp.h>
#include <stdio.h>

#define N 100

int var = 0;

int main(){

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for(int i=0; i<N; i++){
    #pragma omp critical(addlock)
    var++;

    #pragma omp critical(sublock)
    var -= 2;
  }

  printf("%d\n",var);

  return 0;
}
