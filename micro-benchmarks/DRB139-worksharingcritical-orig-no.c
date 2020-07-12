/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */


/*
 * Referred from worksharing_critical.1.c
 * A single thread executes the one and only section in the sections region, and executes the
 * critical region. The same thread encounters the nested parallel region, creates a new team
 * of threads, and becomes the master of the new team. One of the threads in the new team enters
 * the single region and increments i by 1. At the end of this example i is equal to 2.
*/


#include <stdio.h>
#include <omp.h>

int main(){

  int i = 1;

  #pragma omp parallel sections
  {
    #pragma omp section
    {
      #pragma omp critical (name)
      {
        #pragma omp parallel
        {
          #pragma omp single
          {
            i++;
          }
        }
      }
    }
  }

  printf("%d\n",i);
  return 0;
}
