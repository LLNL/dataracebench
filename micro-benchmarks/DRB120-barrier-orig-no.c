/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
The barrier construct specifies an explicit barrier at the point at which the construct appears.
Barrier construct at line:27 ensures that there is no data race.
*/

#include <omp.h>
#include <stdio.h>

int main(int argc, char* argv[])
{
  int var = 0;

  #pragma omp parallel shared(var)
  {
    #pragma omp single
    var++;

    #pragma omp barrier

    #pragma omp single
    var++;
  }

  if(var != 2) printf("%d\n",var);
  int error = (var != 2);
  return error;
}
