/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
A single thread will spawn all the tasks. Add if(0) to avoid the data race, undeferring the tasks.

Data Race pairs var@30:9:W vs. var@30:9:W
*/

#include <omp.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
  int var = 0;
  int i;

  #pragma omp parallel sections
  {
    for (i = 0; i < 10; i++) {
      #pragma omp task shared(var)
      {
        var++;
      }
    }
  }

  if (var!=10) printf("%d\n",var);
  return 0;
}
