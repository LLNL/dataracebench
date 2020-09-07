/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/* This kernel imitates the nature of a program from the NAS Parallel Benchmarks 3.0 MG suit.
 * Use of private clause at 26:28 will ensure that there is no data race. No Data Race Pairs. 
 */


#include <stdio.h>
#include <omp.h>

int main(){
  int i,j,k,m;
  double tmp1;

  double a[12][12][12];

  m = 3.0;

  #pragma omp parallel for private(j,k,tmp1)   
  for (i = 0; i < 12; i++) {
    for (j = 0; j < 12; j++) {
      for (k = 0; k < 12; k++) {
        tmp1 = 6.0/m;
        a[i][j][k] = tmp1+4;
      }
    }
  }

  return 0;
}

