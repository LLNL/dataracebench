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

 * No race. The array b is divided into two non-overlapping halves that are referenced by u[0] and u[1].
 */

#include <stdlib.h>
#include <stdio.h>

double c = 0.2;
int n = 20, nsteps = 100;

int main()
{
  double *b = malloc(2 * n * sizeof(double));
  double *u[2] = {&b[0], &b[n]};
  for (int i = 1; i < n - 1; i++)
    u[0][i] = u[1][i] = 1.0 * rand() / RAND_MAX;
  u[0][0] = u[0][n - 1] = u[1][0] = u[1][n - 1] = 0.5;
  int p = 0;
  for (int t = 0; t < nsteps; t++)
  {
#pragma omp parallel for
    for (int i = 1; i < n - 1; i++)
    {
      u[1 - p][i] = u[p][i] + c * (u[p][i - 1] + u[p][i + 1] - 2 * u[p][i]);
    }
    p = 1 - p;
  }
  for (int i = 0; i < n; i++)
    printf("%1.2lf ", u[p][i]);
  printf("\n");
  free(b);
}
