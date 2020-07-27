/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/* This example is referred from OpenMP Application Programming Interface 5.0, example tasking.7.c
 * A task switch may occur at a task scheduling point. A single thread may execute both of the
 * task regions that modify tp. The parts of these task regions in which tp is modified may be
 * executed in any order so the resulting value of var can be either 1 or 2.
 * There is a  Race pair var@34:7 and var@34:7 but no data race. 
 */


#include <omp.h>
#include <stdio.h>

int tp;
#pragma omp threadprivate(tp)
int var;

int main(){
  #pragma omp task
  {
    #pragma omp task
    {
      tp = 1;
      #pragma omp task
      {
      }
      var = tp;
    }
    tp=2;
  }

  if(var==2) printf("%d\n",var);
  return 0;
}
