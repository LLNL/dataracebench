/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Nowait clause at line 30:58 will cause no implicit barrier after the tasks completion.
Data Race Pairs, x[i]@36:9 and x[i]@36:20; x[i]@40:9 and x[i]@40:16
*/

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define C 64

float a;
float x[C];
float y[C];

int main(){
  for(int i=0; i<C; i++){
    a=5;
    x[i]=0;
    y[i]=3;
  }

  #pragma omp target map(to:y[0:C],a) map(tofrom:x[0:C]) nowait device(0)
  {
    for(int i=0; i<C; i++){
      #pragma omp task depend(inout:x[i])
      {
        x[i] = a * x[i];
      }
      #pragma omp task depend(inout:x[i])
      {
        x[i] = x[i] + y[i];
      }
    }
  }

  for(int i=0; i<C; i++){
    if(x[i]!=3){
      printf("Data Race Detected\n");
      return 0;
    }
  }

  #pragma omp taskwait
  return 0;
}
