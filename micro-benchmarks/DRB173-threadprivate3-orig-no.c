/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * EP.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 EP.
 * Tool                  Race       Read line           Write line
 * Tsan                    N
 * Intel Inspector         Y          29                     29
 * Romp                    N
 * Archer                  N
*/

#include <stdio.h>

static double x[20];
#pragma omp threadprivate(x)


int main(){
  int i;
  double j,k;

  #pragma omp parallel for default(shared) private(i,j,k)
    for (i = 0; i < 20; i++){
        x[i] = -1.0e99;
        j = x[0];
        k = i +0.05;
    }

  return 0;
}
