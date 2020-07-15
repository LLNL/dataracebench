/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/* The initialization of a=0@25:5 is not synchronized with the update of a@29:7 as a result of the
 * reduction computation in the for loop.
 * Data Race pair: a@25:5 and a@29:7
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
      a += i;
    }

    #pragma omp single
    printf("Sum is %d\n", a);
  }

  return 0;
}
