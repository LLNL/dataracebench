/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
A nested lock can be locked several times. It doesn't unlock until you have unset
it as many times as the number of calls to omp_set_nest_lock.
incr_b is called at line 48 and line 53. So, it needs a nest_lock enclosing line 31
Missing nest_lock will lead to race condition at line:31.
Data Race Pairs, p->b@31:3 and p->b@31:10.
*/

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int a, b;
  omp_nest_lock_t lck;
} pair;

int incr_a(pair *p){
  p->a = p->a + 1;
}
int incr_b(pair *p){
  p->b = p->b + 1;
}


int main(int argc, char* argv[])
{
  int var1=0, var2=0;
  pair *p;
  omp_init_nest_lock(&p->lck);

  #pragma omp parallel shared (var1, var2)
  {
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
  }

  omp_destroy_nest_lock(&p->lck);

  int error = (p->a != ((p->b)/2)+1);
  printf("%d\n",p->b);
  return error;
}
