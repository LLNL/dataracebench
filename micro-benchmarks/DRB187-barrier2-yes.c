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

 * not a barrier.  either thread can exit before the other thread
 * enters.  So race on x can occur.
 * Data race pair: x@39:7:W vs. x@51:7:W
 */

#include <stdio.h>
#include <omp.h>
#include <assert.h>

omp_lock_t l0, l1;
int x = 1;

int main()
{
  omp_init_lock(&l0);
  omp_init_lock(&l1);
#pragma omp parallel num_threads(2)
  {
    int tid = omp_get_thread_num();
    if (tid == 0)
      omp_set_lock(&l0);
    else if (tid == 1)
      omp_set_lock(&l1);
#pragma omp barrier
    if (tid == 0)
      x = 0;
    if (tid == 0)
    {
      omp_unset_lock(&l0);
      omp_set_lock(&l0);
    }
    else if (tid == 1)
    {
      omp_unset_lock(&l1);
      omp_set_lock(&l1);
    }
    if (tid == 1)
      x = 1;
#pragma omp barrier
    if (tid == 0)
      omp_unset_lock(&l1);
    else if (tid == 1)
      omp_unset_lock(&l0);
  } // end of parallel construct
  omp_destroy_lock(&l0);
  omp_destroy_lock(&l1);
  printf("Done: x=%d\n", x);
}
