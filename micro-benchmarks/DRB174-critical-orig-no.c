/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * FT.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 FT suit.
 * Tool                  Race       Read line      Write line      Read line     Write line   Read line    Write line
 * Tsan                    Y          34:14           34:14          34:1           26:10
 * Intel Inspector         Y           24              25             3              31          34             34
 * Romp                    N
 * Archer                  N
*/

#include <stdio.h>

int main(){
  int i;
  double q[10], qq[10];

  #pragma omp parallel for default(shared) private(i)
  for (i = 0; i < 10; i++) qq[i] = 1.0;
  for (i = 0; i < 10; i++) q[i] = 0.0;
  /*initial m */
  #pragma omp parallel default(shared) 
  {
    #pragma omp for
      for (i = 0; i <= 10 - 1; i++) q[i] += qq[i];
    #pragma omp critical
      {
        q[i] = 1.0;
      }
    #pragma omp barrier
    #pragma omp single
     {
        q[i] = q[i] - 1.0;
     }

  }
  return 0;
}
