/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Missing dependencies between the addition@39 and multiplication@45 task.
Data Race Pairs: x[i]@39:11 and x[i]@39:22; x[i]@45:11 and x[i]@45:18.
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#define C 32

float a;
float x[C];
float y[C];

int main(){
  for(int i=0; i<C; i++){
    a=5;
    x[i]=0;
    y[i]=3;
  }

  int i;
  #pragma omp target map(to:y[0:C],a) map(tofrom:x[0:C]) device(0)
  {
    #pragma omp teams distribute
    for(i=0; i<2*C; i++){
      if(i%2==0){
        #pragma omp task
        {
          x[i] = a * x[i];
        }
      }else
      {
        #pragma omp task
        {
          x[i] = x[i] + y[i];
        }
      }
    }
  }

  for(int i=0; i<C; i++){
    if(x[i]!=3){
      printf("Data Race Detected\n");
      return 0;
    }
  }
  return 0;
}
