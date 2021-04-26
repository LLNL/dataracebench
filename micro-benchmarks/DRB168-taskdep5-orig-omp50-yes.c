/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* The first two tasks are serialized, because a dependence on the first child is produced
 * by x with the in dependence type in the depend clause of the second task. Generating task
 * at the first taskwait only waits for the first child task to complete. The second taskwait
 * guarantees completion of the second task before y is accessed. If we access y before the
 * second taskwait, there is a race condition at line 28 ann 33. Data Race Pair, y@28:2:W vs. y@33:19:R
 * */


#include <stdio.h>
#include <omp.h>

void foo(){
  int x = 0, y = 2;

  #pragma omp task depend(inout: x) shared(x)
  x++;                                                             // 1st child task

  #pragma omp task depend(in: x) depend(inout: y) shared(x, y)
  y -= x;                                                         //2nd child task

  #pragma omp taskwait depend(in: x)                               // 1st taskwait

  printf("x=%d\n",x);
  printf("y=%d\n",y);

  #pragma omp taskwait		                                         // 2nd taskwait

}

int main(){
  #pragma omp parallel
  #pragma omp single
  foo();

  return 0;
}

