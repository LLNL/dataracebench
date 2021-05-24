/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*This example is referred from DRACC by Adrian Schmitz et al.
The distribute parallel for directive at line 24 will execute loop using multiple teams.
The loop iterations are distributed across the teams in chunks in round robin fashion.
The missing lock enclosing var@26:5 leads to data race. Data Race Pairs, var@26:5:W vs. var@26:5:W
*/

#include <omp.h>
#include <stdio.h>

int main(){

  int var=0,i;

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<100; i++){
    var++;
  }

  printf("%d\n",var);
  return 0;
}
