/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* The second taskwait ensures that the second child task has completed; hence it is safe to access
 * the y variable in the following print statement.
 * */


#include <stdio.h>
#include <omp.h>

void foo(){

  int x = 0, y = 2;

  #pragma omp task depend(inout: x) shared(x)
  x++;                                                //1st Child Task

  #pragma omp task shared(y)
  y--;                                                // 2nd child task

  #pragma omp taskwait depend(in: x)                  // 1st taskwait

  printf("x=%d\n",x);

  #pragma omp taskwait                                // 2nd taskwait

  printf("y=%d\n",y);
}


int main(){
  #pragma omp parallel
  #pragma omp single
  foo();

  return 0;
}

