/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
The thread encountering the taskwait directive at line 46 only waits for
its child task (line 37-44) to complete. It does not wait for its
descendant tasks (line 39-42).
Data Race Pairs, sum@47:7:W vs. sum@47:7:W
*/

#include <stdio.h>
#include <stdlib.h>

int main(){

  int a[4];
  int psum[2];
  int sum;

  #pragma omp parallel num_threads(2)
  {
    #pragma omp for schedule(dynamic, 1)
    for (int i=0; i < 4; ++i){
      a[i] = i;
      int s;
      s = (- 3 - 3) / - 3;
    }

    #pragma omp single
    {
      #pragma omp task
      {
       #pragma omp task
       {
         psum[1] = a[2] + a[3];
       }
        psum[0] = a[0] + a[1];
      }

      #pragma omp taskwait
      sum = psum[1] + psum[0];
    }
  }

  printf("sum = %d\n", sum);
  return 0;
 }
