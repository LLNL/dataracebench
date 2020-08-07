/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/**
 * CG.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 CG.
 * Tool                  Race       Read line           Write line
 * Tsan                    Y            37:23                37:21
 * Intel Inspector         Y            37                   37
 * Romp                    Y            37:21                37:29
 * Archer                  Y            37:23                37:21
 */

#include <stdio.h>
#include <math.h>

static int colidx[100];

int main(){
  int i,j,k;

  /*initial collide */
  for(i=0; i<100; i++){
    colidx[i] = 1;
  }

  #pragma omp parallel default(shared) private(j,k)
  {
    #pragma omp for nowait
      for (j = 1; j <= 100 ; j++) {
        for (k = 1; k < 99; k++) {
          colidx[k] = colidx[k] - 9;
        }
      }
  }
  return 0;
}
