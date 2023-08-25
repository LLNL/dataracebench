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
Adding a fixed array element to the whole array. Data race present.
Data Race Pairs, a[i]@30:5:W vs. a[64]@30:19:R
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int main(int argc, char *argv[]) {
  int len = 20000;
  if (argc > 1)
    len = atoi(argv[1]);
  double a[len];
  for (int i = 0; i < len; i++)
    a[i] = i;
  double c = M_PI;

#pragma omp parallel for simd schedule(dynamic, 64)
  for (int i = 0; i < len; i++)
    a[i] = a[i] + a[64];

  printf("a[0]=%f, a[%i]=%f, a[%i]=%f\n", a[0], len / 2, a[len / 2], len - 1,
         a[len - 1]);
  return 0;
}
