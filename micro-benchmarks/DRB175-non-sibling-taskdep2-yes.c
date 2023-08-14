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
 * Data race between non-sibling tasks created from different implicit tasks 
 * with declared task dependency
 * Derived from code in https://hal.archives-ouvertes.fr/hal-02177469/document,
 * Listing 1.3
 * Schedule forced to execute all tasks by different threads.
 * Data Race Pair, a@33:7:W vs. a@33:7:W
 * */

#include <omp.h>
#include <stdio.h>
#include "signaling.h"

void foo() {
  int a = 0, sem = 0;

#pragma omp parallel
  {
#pragma omp task depend(inout : a) shared(a)
    {
      SIGNAL(sem);
      WAIT(sem, omp_get_num_threads());
      a++;
    }
  }
  printf("a=%d\n", a);
}

int main() {
  foo();

  return 0;
}
