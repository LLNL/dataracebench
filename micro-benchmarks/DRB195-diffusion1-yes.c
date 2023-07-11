/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
 * This is a program based on a dataset contributed by
 * Wenhao Wu and Stephen F. Siegel @Univ. of Delaware.

 * Race due to u1 and u2 are aliased.
 * Data race pairs: u2[i]@39:7:W vs. u1[i]@39:15:R
 *                  u2[i]@39:7:W vs. u1[i - 1]@39:28:R
 *                  u2[i]@39:7:W vs. u1[i + 1]@39:40:R
 *                  u2[i]@39:7:W vs. u1[i]@39:56:R
 */

#include <stdlib.h>
#include <stdio.h>

double *u1, *u2, c = 0.2;
int n = 10, nsteps = 10;

int main()
{
  u1 = malloc(n * sizeof(double));
  u2 = malloc(n * sizeof(double));
  for (int i = 1; i < n - 1; i++)
    u2[i] = u1[i] = 1.0 * rand() / RAND_MAX;
  u1[0] = u1[n - 1] = u2[0] = u2[n - 1] = 0.5;
  for (int t = 0; t < nsteps; t++)
  {
#pragma omp parallel for
    for (int i = 1; i < n - 1; i++)
    {
      u2[i] = u1[i] + c * (u1[i - 1] + u1[i + 1] - 2 * u1[i]);
    }
    double *tmp = u1;
    u1 = u2; // u2 = tmp;
  }
  for (int i = 0; i < n; i++)
    printf("%1.2lf ", u1[i]);
  printf("\n");
  free(u1);
  free(u2);
}
