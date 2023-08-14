/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file
for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* 
 * Data race between non-sibling tasks with declared task dependency
 * Derived from code in https://hal.archives-ouvertes.fr/hal-02177469/document,
 * Listing 1.1
 * Data Race Pair, a@32:9:W vs. a@42:9:W
 * */

#include <omp.h>
#include <stdio.h>
#include "signaling.h"

void foo() {
  int a = 0, sem = 0;

#pragma omp parallel num_threads(2)
#pragma omp single
  {
#pragma omp task depend(inout : a) shared(a)
    {
#pragma omp task depend(inout : a) shared(a)
      {
        a++;
        SIGNAL(sem);
        WAIT(sem,2);
      }
    }

#pragma omp task depend(inout : a) shared(a)
    {
#pragma omp task depend(inout : a) shared(a)
      {
        a++;
        SIGNAL(sem);
        WAIT(sem,2);
      }
    }
    // allow other thread to steal first task
    WAIT(sem,1);
  }

  printf("a=%d\n", a);
}

int main() {
  foo();

  return 0;
}
