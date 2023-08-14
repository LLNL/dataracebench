/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* Due to the missing mutexinoutset dependence type on c, these tasks will execute in any
 * order leading to the data race at line 36. 
 * Data Race Pair, c@32:7:W vs. c+@41:7:W
                   c@32:7:W vs. c+@47:7:W
                   c+@41:7:W vs. c+@47:7:W
                   c+@41:7:W vs. c@50:11:W
                   c+@47:7:W vs. c@50:11:W
 * */


#include <stdio.h>
#include <omp.h>
#include "signaling.h"

int main(){
  int a, b, c, d, sem = 0;

  #pragma omp parallel num_threads(2)
  #pragma omp single
  {
    #pragma omp task depend(out: c)
      c = 1;
    #pragma omp task depend(out: a)
      a = 2;
    #pragma omp task depend(out: b)
      b = 3;
    #pragma omp task depend(in: a)
    {
      SIGNAL(sem);
      WAIT(sem,2);
      c += a;
    }
    #pragma omp task depend(in: b)
    {
      SIGNAL(sem);
      WAIT(sem,2);
      c += b;
    }
    #pragma omp task depend(in: c)
      d = c;
  }

  printf("%d\n",d);
  return 0;
}
