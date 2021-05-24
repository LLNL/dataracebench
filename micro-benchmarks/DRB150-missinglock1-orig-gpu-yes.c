/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
The distribute parallel for directive at line 27 will execute loop using multiple teams.
The loop iterations are distributed across the teams in chunks in round robin fashion.
The omp lock is only guaranteed for a contention group, i.e, within a team. Data Race Pair, var@30:5:W vs. var@30:5:W
*/


#include <omp.h>
#include <stdio.h>

int main(){

  omp_lock_t lck;
  int var=0,i;
  omp_init_lock(&lck);

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute parallel for
  for (int i=0; i<100; i++){
    omp_set_lock(&lck);
    var++;
    omp_unset_lock(&lck);
  }

  omp_destroy_lock(&lck);

  printf("%d\n",var);
  return 0;
}
