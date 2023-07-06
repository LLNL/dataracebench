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
 
 * implements 2-thread reuseable barrier using 3 locks, no race.
 */

#include <stdio.h>
#include <omp.h>
#include <assert.h>

omp_lock_t l0, l1, l2;
const int n = 100;
int x = 1;

void barrier_init()
{
  omp_init_lock(&l0);
  omp_init_lock(&l1);
  omp_init_lock(&l2);
}

void barrier_destroy()
{
  omp_destroy_lock(&l0);
  omp_destroy_lock(&l1);
  omp_destroy_lock(&l2);
}

void barrier_start(int tid)
{
  if (tid == 0)
  {
    omp_set_lock(&l0);
    omp_set_lock(&l2);
  }
  else if (tid == 1)
  {
    omp_set_lock(&l1);
  }
}

void barrier_stop(int tid)
{
  if (tid == 0)
  {
    omp_unset_lock(&l0);
    omp_unset_lock(&l2);
  }
  else if (tid == 1)
  {
    omp_unset_lock(&l1);
  }
}

void barrier_wait(int tid)
{
  if (tid == 0)
  {
    omp_unset_lock(&l0);
    omp_set_lock(&l1);
    omp_unset_lock(&l2);
    omp_set_lock(&l0);
    omp_unset_lock(&l1);
    omp_set_lock(&l2);
  }
  else if (tid == 1)
  {
    omp_set_lock(&l0);
    omp_unset_lock(&l1);
    omp_set_lock(&l2);
    omp_unset_lock(&l0);
    omp_set_lock(&l1);
    omp_unset_lock(&l2);
  }
}

int main()
{
  barrier_init();
#pragma omp parallel num_threads(2)
  {
    int tid = omp_get_thread_num();
    barrier_start(tid);
#pragma omp barrier
    for (int i = 0; i < n; i++)
    {
      printf("Thread %d: phase 1, i=%d, x=%d\n", tid, i, x);
      fflush(stdout);
      assert(x == 1);
      barrier_wait(tid);
      if (tid == 0)
        x = 0;
      barrier_wait(tid);
      printf("Thread %d: phase 3, i=%d, x=%d\n", tid, i, x);
      fflush(stdout);
      assert(x == 0);
      barrier_wait(tid);
      if (tid == 1)
        x = 1;
      barrier_wait(tid);
    }
#pragma omp barrier
    barrier_stop(tid);
  } // end of parallel construct
  barrier_destroy();
  printf("Done: x=%d\n", x);
}
