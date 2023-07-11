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

 * Thread with id 1 acquires and releases the lock, but then it modifies x without holding it.
 * Data race pair: size@35:7:W vs. size@42:7:W
 */

#include <stdio.h>
#include <omp.h>
#include <assert.h>

omp_lock_t l;
int x = 1;

int main()
{
  omp_init_lock(&l);
#pragma omp parallel num_threads(2)
  {
    int tid = omp_get_thread_num();
#pragma omp barrier
    if (tid == 0)
    {
      omp_set_lock(&l);
      x = 0;
      omp_unset_lock(&l);
    }
    else if (tid == 1)
    {
      omp_set_lock(&l);
      omp_unset_lock(&l);
      x = 1;
    }
#pragma omp barrier
  } // end of parallel construct
  omp_destroy_lock(&l);
  printf("Done: x=%d\n", x);
}