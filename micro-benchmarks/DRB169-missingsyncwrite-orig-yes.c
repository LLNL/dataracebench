/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/* This kernel imitates the nature of a program from the NAS Parallel Benchmarks 3.0 MG suit.
 * Due to missing construct to write r1[k]@38:9 synchronously, there is a Data Race.
 * Data Race Pair, r1[k]@38:9:W vs. r1[k]@38:9:W
 * */

#include <stdio.h>
#include <omp.h>

#define N 8

int main()
{
  int i,j,k;
  double r1[N], r[N][N][N];

  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      for (k = 0; k < N; k++) {
        r[i][j][k] = i;
      }
    }
  }


  #pragma omp parallel for default(shared) private(j,k)
  for (i = 1; i < N-1; i++) {
    for (j = 1; j < N-1; j++) {
      for (k = 0; k < N; k++) {
        r1[k] = r[i][j-1][k] + r[i][j+1][k] + r[i-1][j][k] + r[i+1][j][k];
      }
    }
  }

  for (k = 0; k < N; k++) printf("%f ",r1[k]);

  printf("\n");

  return 0;
}

