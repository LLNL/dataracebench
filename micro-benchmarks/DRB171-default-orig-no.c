/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * MG.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 MG.
 * Tsan and Intel Inspector report a false postive.
*/

#include <stdio.h>
#define M 1037

int main(int argh, char* argv[])
{
  int i3,i2,i1,n;
  double r1[M], r2[M], r[34][34][34];
  int k = 32;
  n = 34;

  for (i3 = 0; i3 < n; i3++) {
    for (i2 = 0; i2 < n; i2++) {
      for (i1 = 0; i1 < n; i1++) {
        r[i3][i2][i1] = 1;
      }
    }
  }
  #pragma omp parallel for default(shared) private(i1,i2,i3,r1,r2)
  for (i3 = 1; i3 < n-1; i3++) {
    for (i2 = 1; i2 < n-1; i2++) {
      for (i1 = 0; i1 < n; i1++) {
        r1[i1] = r[i3][i2-1][i1] + r[i3][i2+1][i1]
               + r[i3-1][i2][i1] + r[i3+1][i2][i1];
        r2[i1] = r[i3-1][i2-1][i1] + r[i3-1][i2+1][i1]
               + r[i3+1][i2-1][i1] + r[i3+1][i2+1][i1];
      }
    }
  }
  return 0;
}
