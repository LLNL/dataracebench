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

 * Race due to different critical section names
 * Data race pair: x@27:7:W vs. x@44:7:W
 * Data race pair: s@30:9:W vs. s@40:15:R
 */

#include <stdio.h>
int main()
{
  int x = 0, s = 0;
#pragma omp parallel sections shared(x, s) num_threads(2)
  {
#pragma omp section
    {
      x = 1;
#pragma omp critical(A)
      {
        s = 1;
      }
    }
#pragma omp section
    {
      int done = 0;
      while (!done)
      {
#pragma omp critical(B)
        {
          if (s)
            done = 1;
        }
      }
      x = 2;
    }
  }
  printf("%d\n", x);
}
