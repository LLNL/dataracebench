/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* Addition of mutexinoutset dependence type on c, will ensure that line d@37:7 assignment will depend
 * on task at Line 32 and line 34. They might execute in any order but not at the same time.
 * There is no data race.
 * */


#include <stdio.h>
#include <omp.h>

int main(){
  int a, b, c, d;

  #pragma omp parallel
  #pragma omp single
  {
    #pragma omp task depend(out: c)
      c = 1;
    #pragma omp task depend(out: a)
      a = 2;
    #pragma omp task depend(out: b)
      b = 3;
    #pragma omp task depend(in: a) depend(mutexinoutset: c)
      c += a;
    #pragma omp task depend(in: b) depend(mutexinoutset: c)
      c += b;
    #pragma omp task depend(in: c)
      d = c;
  }

  printf("%d\n",d);
  return 0;
}
