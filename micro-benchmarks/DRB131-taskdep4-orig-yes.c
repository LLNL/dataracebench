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
 * Data Race at y@33:19 and y@33:19
*/

#include <stdio.h>
#include <omp.h>

void foo(){

  int x = 0, y = 2;

  #pragma omp task depend(inout: x) shared(x)
  x++;                                                //1st Child Task

  #pragma omp task shared(y)
  y--;                                                // 2nd child task

#if _OPENMP < 201811
  #pragma omp task depend(in: x) if(0)                // 1st taskwait
  {}
#else
  #pragma omp taskwait depend(in: x)                  // 1st taskwait
#endif

  printf("x=%d\n",x);
  printf("y=%d\n",y);
  #pragma omp taskwait                                // 2nd taskwait
}


int main(){
  #pragma omp parallel
  #pragma omp single
  foo();

  return 0;
}
