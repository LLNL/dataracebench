/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Number of threads is empirical: We need enough threads so that
the reduction is really performed hierarchically in the barrier!
There is no data race.
*/


#include <omp.h>
#include <stdio.h>

int main(int argc, char* argv[])
{
  int var = 0, i, res;
  int sum1 = 0;
  int sum2 = 0;

  #pragma omp parallel reduction(+: var)
  {
		res = omp_get_num_threads();
    #pragma omp for schedule(static) reduction(+: sum1)
    for (i=0; i<5; i++)
    sum1+=i;
    #pragma omp for schedule(static) reduction(+: sum2)
    for (i=0; i<5; i++)
    sum2+=i;

    var = sum1 + sum2;
  }

	int error = (var != 20*res);
	printf("%d %d\n",var,20*res);
  return error;
}
