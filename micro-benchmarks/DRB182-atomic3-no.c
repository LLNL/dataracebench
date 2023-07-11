/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

#include <stdio.h>
/*
 * This is a program based on a dataset contributed by 
 * Wenhao Wu and Stephen F. Siegel @Univ. of Delaware.
 
 * sync with busy wait loop using atomic. No data race pair.
 */
int main()
{
  int x = 0, s = 0;
#pragma omp parallel sections shared(x, s) num_threads(2)
  {
#pragma omp section
    {
      x = 1;
#pragma omp atomic write seq_cst
      s = 1;
    }
#pragma omp section
    {
      int done = 0;
      while (!done)
      {
#pragma omp atomic read seq_cst
        done = s;
      }
      x = 2;
    }
  }
  printf("%d\n", x);
}
