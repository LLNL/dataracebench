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
 
 * single producer single consumer with critical sections
 */

#include <stdio.h>

int cap = 10, size = 0, packages = 1000;
unsigned r = 0;

int main()
{
#pragma omp parallel sections shared(size, cap) firstprivate(r, packages) num_threads(2)
  {
#pragma omp section
    while (packages)
    {
#pragma omp critical
      {
        if (size < cap)
        {
          size++; // produce
          packages--; // produced a package
          printf("Produced! size=%d\n", size);
          fflush(stdout);
        }
      }
      for (int i = 0; i < 1000; i++)
        r = (r + 1) % 10;
    }
#pragma omp section
    while (packages)
    {
#pragma omp critical
      {
        if (size > 0)
        {
          size--; // consume
          packages--; // consumed a package
          printf("Consumed! size=%d\n", size);
          fflush(stdout);
        }
      }
      for (int i = 0; i < 1500; i++)
        r = (r + 1) % 10;
    }
  }
}
