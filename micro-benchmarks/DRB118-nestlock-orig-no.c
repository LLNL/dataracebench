/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/* This example is modified version of nestable_lock.1.c example, OpenMP 5.0 Application Programming Examples.
A nested lock can be locked several times. It doesn't unlock until you have unset
it as many times as the number of calls to omp_set_nest_lock.
incr_b is called at line 47 and line 52. So, it needs a nest_lock for p->b@30:4.
*/

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int a, b;
  omp_nest_lock_t lck;
} pair;

void incr_a(pair *p){
  p->a += 1;
}
void incr_b(pair *p){
  omp_set_nest_lock(&p->lck);
    p->b += 1;
  omp_unset_nest_lock(&p->lck);
}


int main(int argc, char* argv[])
{
  pair p[1];
  p->a = 0;
  p->b = 0;
  omp_init_nest_lock(&p->lck);

  #pragma omp parallel sections
  {
    #pragma omp section
    {
      omp_set_nest_lock(&p->lck);
      incr_b(p);
      incr_a(p);
      omp_unset_nest_lock(&p->lck);
    }
    #pragma omp section
      incr_b(p);
  }

  omp_destroy_nest_lock(&p->lck);

  printf("%d\n",p->b);
  return 0;
}
