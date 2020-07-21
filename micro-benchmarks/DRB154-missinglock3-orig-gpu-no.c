/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
Concurrent accessing var@27:5 may cause atomicity violation and inter region data race.
Lock and reduction clause at line 24, avoids this. No Data Race Pair.
*/

#include <stdio.h>
#include <omp.h>

int main(){
  omp_lock_t lck;
  int var = 0;
  omp_init_lock(&lck);

  #pragma omp target map(tofrom:var) device(0)
  #pragma omp teams distribute reduction(+:var)
  for (int i=0; i<100; i++){
    omp_set_lock(&lck);
    var++;
    omp_unset_lock(&lck);
  }

  omp_destroy_lock(&lck);
  printf("%d\n ",var);
  return 0;
}
