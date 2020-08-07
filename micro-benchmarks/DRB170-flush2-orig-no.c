/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * LU.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 LU.
 * Tool                  Race       Read line    Write line   Read line   Write line    R line   W line
 * Tsan                    Y            72:32         51:18       64:14        64:14    65:16   65:16
 * Intel Inspector         Y            51            72          72           71       64        64
 * Romp                    Y            65:29         65:16       51:22        72:32    64:29    65:16
 * Archer                  Y            66:25         66:25       51:18        72:32    65:16    65:16
*/

#include <stdio.h>
#include <stdbool.h>

static bool flag[12/2*2+1];

int main()
{
  int i,j,k,m,ist,iend,jst,jend;
  double omega;
  double v[12][12/2*2+1][12/2*2+1][5];
  omega = 1.2;
  ist = 1;
  iend = 10;
  jst =1;
  jend = 10;
  
/* inintal value */
  for (i = 0; i < 12; i++) {
    for (j = 0; j < 12; j++) {
      for (k = 0; k < 12; k++) {
        for (m = 0; m < 5; m++) {
            v[i][j][k][m] = i + j +  k;
        }
      }
    }
  }
  #pragma omp parallel private(k)
  {
    for(k = 1; k <= 12 - 2; k++){
      #pragma omp for nowait schedule(static)
      for (i = ist; i <= iend; i++) {
        #if defined(_OPENMP)
        if (i != ist) {
          while (flag[i-1] == 0) {
            #pragma omp flush(flag)
            ;
          }
        }
        if (i != iend) {
          while (flag[i] == 1) {
            #pragma omp flush(flag)
            ;
          }
        }
        #endif /* _OPENMP */
        
      for (j = jst; j<= jend; j++) {
        for (m = 0; m < 5; m++) {
          v[i][j][k][m] = v[i][j][k][m] - omega * v[i][j-1][k][0];
        }
      }

      #if defined(_OPENMP)
        if (i != ist) flag[i-1] = 0;
        if (i != iend) flag[i] = 1;
        #pragma omp flush(flag)
      #endif /* _OPENMP */
      }
    }
  }
  return 0;
}
