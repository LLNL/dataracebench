/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Data race in vectorizable code
Loop depencency with 64 element offset. Data race present.
Data Race Pairs, a[i + 64]@34:5:W vs. a[i]@34:17:R
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int len = 20000;

  if (argc > 1)
    len = atoi(argv[1]);
  double a[len], b[len];

  for (int i = 0; i < len; i++) {
    a[i] = i;
    b[i] = i + 1;
  }

#pragma omp parallel for simd schedule(dynamic, 64)
  for (int i = 0; i < len - 64; i++)
    a[i + 64] = a[i] + b[i];

  printf("a[0]=%f, a[%i]=%f, a[%i]=%f\n", a[0], len / 2, a[len / 2], len - 1,
         a[len - 1]);

  return 0;
}
