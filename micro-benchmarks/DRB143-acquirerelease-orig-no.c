/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* The explicit flush directive that provides at line:29 provides release semantics is needed
 * here to complete the synchronization. No data race.
 * */


#include <stdio.h>
#include <omp.h>

int main(){

  int x = 0, y;

  #pragma omp parallel num_threads(2)
  {
  int thrd = omp_get_thread_num();
  if (thrd == 0) {
    #pragma omp critical
    { x = 10; }

    #pragma omp flush(x)

    #pragma omp atomic write
    y = 1;
  } else {
      int tmp = 0;
      while (tmp == 0) {
      #pragma omp atomic read acquire
      tmp = y;
      }
    #pragma omp critical
    { if (x!=10) printf("x = %d\n", x); }
  }
  }
  return 0;
}
