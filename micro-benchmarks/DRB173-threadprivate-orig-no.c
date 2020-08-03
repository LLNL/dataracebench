/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * EP.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 EP suit.
 * Intel Inspector can not correctly analyze the threadprivate, and report a false postive.
*/

#include <stdio.h>

static double x[20];
#pragma omp threadprivate(x)


int main(int argh, char* argv[]){
  int i,m,n;
  double j,k;
  int p[12][12][12];

  #pragma omp parallel for default(shared) private(i,j,k,m,n)
    for (i = 0; i < 20; i++){
        x[i] = -1.0e99;
        j = x[0];
        k = i +0.05;
    }

  return 0;
}
