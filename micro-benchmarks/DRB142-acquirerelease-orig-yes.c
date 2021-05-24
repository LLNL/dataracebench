/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* The below program will fail to order the write to x on thread 0 before the read from x on thread 1.
 * The implicit release flush on exit from the critical region will not synchronize with the acquire
 * flush that occurs on the atomic read operation performed by thread 1. This is because implicit
 * release flushes that occur on a given construct may only synchronize with implicit acquire flushes
 * on a compatible construct (and vice-versa) that internally makes use of the same synchronization
 * variable.
 *
 * Implicit flush must be used after critical construct, after line:34 and before line:35 to avoid data race.
 * Data Race pair: x@34:9:W vs. x@34:9:W
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
