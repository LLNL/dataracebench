/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* Due to the missing mutexinoutset dependence type on c, these tasks will execute in any
 * order leading to the data race at line 36. Data Race Pair, d@36:7:W vs. d@36:7:W
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
    #pragma omp task depend(in: a)
      c += a;
    #pragma omp task depend(in: b)
      c += b;
    #pragma omp task depend(in: c)
      d = c;
  }

  printf("%d\n",d);
  return 0;
}
