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
 
 * 2-thread flag barrier using busy-wait loops and critical, no race.
 */

#include <stdio.h>
#include <omp.h>
#include <assert.h>

typedef _Bool flag_t;

flag_t f0, f1;
const int n = 100;
int x = 1;

void init(flag_t *f)
{
  *f = 0;
}

void raise(flag_t *f)
{
#pragma omp critical
  {
    assert(*f == 0);
    *f = 1;
  }
}

void lower(flag_t *f)
{
  _Bool done = 0;
  while (!done)
  {
#pragma omp critical
    if (*f == 1)
    {
      *f = 0;
      done = 1;
    }
  }
}

void mybarrier(int tid)
{
  if (tid == 0)
  {
    raise(&f0);
    lower(&f1);
  }
  else if (tid == 1)
  {
    lower(&f0);
    raise(&f1);
  }
}

int main()
{
  init(&f0);
  init(&f1);
#pragma omp parallel num_threads(2)
  {
    int tid = omp_get_thread_num();
#pragma omp barrier
    for (int i = 0; i < n; i++)
    {
      printf("Thread %d: phase 1, i=%d, x=%d\n", tid, i, x);
      fflush(stdout);
      assert(x == 1);
      mybarrier(tid);
      if (tid == 0)
        x = 0;
      mybarrier(tid);
      printf("Thread %d: phase 3, i=%d, x=%d\n", tid, i, x);
      fflush(stdout);
      assert(x == 0);
      mybarrier(tid);
      if (tid == 1)
        x = 1;
      mybarrier(tid);
    }
  } // end of parallel construct
  printf("Done: x=%d\n", x);
}