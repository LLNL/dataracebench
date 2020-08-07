/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * SP.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 SP suit.
 * Tool                  Race       Read lin    Write line   Read line   Write line
 * Tsan                   Y           31:34       28:18       31:14         28:18
 * Intel Inspector        Y             28         24          31            31
 * Romp                   SF
 * Archer                 Y           31:34       31:34
*/

#include <stdio.h>

int main(){
  int i,j;
  int q[10];
  
  #pragma omp parallel private(i)
    for( i=0; i<10; i++){
       #pragma omp master
        {
            q[i] = i;
        }
        #pragma omp barrier
        for (j=0; j<10;j++) q[j] = 0;
    }
}
