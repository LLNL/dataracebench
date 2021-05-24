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
 * Data Race Pair, a@30:7:W vs. a@36:7:W
 * */

#include <omp.h>
#include <stdio.h>

void foo() {
  int a = 0;

#pragma omp parallel
#pragma omp single
  {
#pragma omp task depend(inout : a) shared(a)
    {
#pragma omp task depend(inout : a) shared(a)
      a++;
    }

#pragma omp task depend(inout : a) shared(a)
    {
#pragma omp task depend(inout : a) shared(a)
      a++;
    }
  }

  printf("a=%d\n", a);
}

int main() {
  foo();

  return 0;
}
