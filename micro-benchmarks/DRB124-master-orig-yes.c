/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/


/*
This example is derived from an example by Simone Atzeni, NVIDIA.

Description: Race on variable init. The variable is written by the
master thread and concurrently read by the others.

Solution: master construct at line 31:17 does not have an implicit barrier better
use single. Data Race Pair, init@33:7:W vs. init@36:13:R
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>

int main (int argc, char **argv)
{
  int init, local;

  #pragma omp parallel shared(init) private(local)
  {
    #pragma omp master
    {
      init = 10;
    }

    local = init;
  }

  return 0;
}


