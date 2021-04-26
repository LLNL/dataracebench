/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* The assignment to a@25:7 is  not synchronized with the update of a@29:11 as a result of the
 * reduction computation in the for loop.
 * Data Race pair: a@25:5:W vs. a@27:33:W
 * */

#include <stdio.h>
#include <omp.h>

int main(){
  int a, i;

  #pragma omp parallel shared(a) private(i)
  {
    #pragma omp master
    a = 0;

    #pragma omp for reduction(+:a)
    for (i=0; i<10; i++){
      a = a + i;
    }

    #pragma omp single
    printf("Sum is %d\n", a);
  }

  return 0;
}
