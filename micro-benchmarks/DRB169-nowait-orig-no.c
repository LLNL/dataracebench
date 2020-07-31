/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/**
 * CG.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 CG suit.
 * Tsan and Intel Inspector can not correctly analysis the nowaite, and report a false postive.
 */

#include <stdio.h>
#include <math.h>

#define NA     1400
#define NONZER 7
#define NZ     NA*(NONZER+1)*(NONZER+1)+NA*(NONZER+2)

static int colidx[NZ+1];
static int firstrow;
static int lastrow;
static int firstcol;
static int lastcol;

int main(int argh, char* argv[]){
  int i,j,k;
  firstrow = 1;
  lastrow  = NA;
  firstcol = 1;
  lastcol  = NA;


  /*initial collide */

  for(i=0; i<NZ; i++){
    colidx[i] = 1;
  }

  #pragma omp parallel default(shared) private(i,j,k)
  {
    #pragma omp for nowait
      for (j = 1; j <= lastrow - firstrow + 1; j++) {
        for (k = 1; k < lastcol-firstcol; k++) {
          colidx[k] = colidx[k] - firstcol + 1;
        }
      }
  }

  return 0;
}
