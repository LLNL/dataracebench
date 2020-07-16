/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Vector addition followed by multiplication involving the same var should have a barrier in between.
Here we have an implicit barrier after parallel for regions. No data race pair.
*/

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define N 100
#define C 8


int a;
int b[C];
int c[C];
int temp[C];

int main(){
  for(int i=0; i<C; i++){
    b[i]=0;
    c[i]=2;
    temp[i]=0;
  }
  a=2;

  #pragma omp target map(tofrom:b[0:C]) map(to:c[0:C],temp[0:C],a) device(0)
  #pragma omp parallel
  {
    for(int i=0; i<N ;i++){
      #pragma omp for
      for(int i=0; i<C; i++){
        temp[i] = b[i] + c[i];
      }

      #pragma omp for
      for(int i=C-1; i>=0; i--){
        b[i] = temp[i] * a;
      }
    }
  }

  int val = 0;

  for(int i=0; i<N; i++){
    val = val + 2;
    val = val * 2;
  }

  for(int i=0; i<C; i++){
    if(b[i]!=val){
      printf("expected %d real %d \n",val, b[i]);
      return 0;
    }
  }

  return 0;
}
