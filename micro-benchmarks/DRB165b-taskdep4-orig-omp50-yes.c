/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
 * There is no completion restraint on the second child task. Hence, immediately after the first
 * taskwait it is unsafe to access the y variable since the second child task may still be
 * executing.
 * Data Race at y@36:4:W vs. y@42:19:R
*/

#include <stdio.h>
#include <omp.h>
#include "signaling.h"

int sem = 0;

void foo(){

  int x = 0, y = 2;

  #pragma omp task depend(inout: x) shared(x, sem)
  {
    SIGNAL(sem);
  x++;                                                //1st Child Task
  }

  #pragma omp task shared(y, sem)
  {
    SIGNAL(sem);
  y--;                                                // 2nd child task
  }

  #pragma omp taskwait depend(in: x)                  // 1st taskwait

  printf("x=%d\n",x);
  printf("y=%d\n",y);
  #pragma omp taskwait                                // 2nd taskwait
}


int main(){
  #pragma omp parallel
  {
    #pragma omp masked
  foo();
    WAIT(sem, 2);
  }

  return 0;
}
