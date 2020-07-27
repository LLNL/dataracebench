/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

 /*
 * The scheduling constraints prohibit a thread in the team from executing
 * a new task that modifies tp while another such task region tied to
 * the same thread is suspended. Therefore, the value written will
 * persist across the task scheduling point.
 * No Data Race at var@35:7
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
  }
  return 0;
}
