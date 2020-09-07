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
 * guarantees completion of the second task before y is accessed. Therefore there is no race
 * condition.
 * */


#include <stdio.h>
#include <omp.h>

void foo(){
  int x = 0, y = 2;

  #pragma omp task depend(inout: x) shared(x)
  x++;                                                                  // 1st child task

  #pragma omp task depend(in: x) depend(inout: y) shared(x, y)
  y = y-x;                                                              //2nd child task

  #pragma omp taskwait depend(in: x)                                    // 1st taskwait

  printf("x=%d\n",x);

  #pragma omp taskwait                                                  // 2nd taskwait

  printf("y=%d\n",y);
}

int main(){
  #pragma omp parallel
  #pragma omp single
  foo();

  return 0;
}

