/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* Due to the missing mutexinoutset dependence type on c, these tasks will execute in any
 * order leading to the data race at line 36. Data Race Pair, 
   c@35:7:W vs. c@35:7:W
   c@35:7:W vs. c@39:11:R
   c@37:7:W vs. c@39:11:R
 * */


#include <stdio.h>
#include <omp.h>
#include "signaling.h"

int main(){
  int a, b, c, d, sem = 0;

  #pragma omp parallel num_threads(2)
  {
  #pragma omp masked
  {
    #pragma omp task depend(out: c)
    {
      SIGNAL(sem);
      c = 1;
    }
    #pragma omp task depend(out: a)
    {
      SIGNAL(sem);
      a = 2;
    }
    #pragma omp task depend(out: b)
    {
      SIGNAL(sem);
      b = 3;
    }
    #pragma omp task depend(in: a)
    {
      SIGNAL(sem);
      c += a;
    }
    #pragma omp task depend(in: b)
    {
      SIGNAL(sem);
      c += b;
    }
    #pragma omp task depend(in: c)
    {
      SIGNAL(sem);
      d = c;
    }
    #pragma omp taskwait
  }
  WAIT(sem, 6);
  }

  printf("%d\n",d);
  return 0;
}
