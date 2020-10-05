/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* 
 * Fibonacci code without data race
 * No Data Race Pair
 * */

#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
  int i, j, s;
  if (n < 2)
    return n;
#pragma omp task shared(i) depend(out : i)
  i = fib(n - 1);
#pragma omp task shared(j) depend(out : j)
  j = fib(n - 2);
#pragma omp task shared(i, j) depend(in : i, j)
  s = i + j;
#pragma omp taskwait
  return i + j;
}

int main(int argc, char **argv) {
  int n = 10;
  if (argc > 1)
    n = atoi(argv[1]);
#pragma omp parallel sections
  { printf("fib(%i) = %i\n", n, fib(n)); }
  return 0;
}
