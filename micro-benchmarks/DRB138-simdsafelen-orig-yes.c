/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* The safelen(2) clause at safelen(2)@24:20 guarantees that the vector code is safe for vectors
 * up to 2 (inclusive). In the loop, m@25:12 can be 2 or more for the correct execution. If the
 * value of m is less than 2, the behavior is undefined.
 * Data Race Pair: b[i]@26:5:W vs. b[i-m]@26:12:R
 * */

#include <stdio.h>
#include <omp.h>

int main(){

  int i, m=1, n=4;
  int b[4] = {};

  #pragma omp simd safelen(2)
  for (i = m; i<n; i++)
    b[i] = b[i-m] - 1.0f;

  printf("Expected: -1; Real: %d\n",b[3]);
  return 0;
}
