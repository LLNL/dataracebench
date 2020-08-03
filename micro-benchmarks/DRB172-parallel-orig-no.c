/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */
/**
 * BT.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 bt suit.
 * Tsan and Intel Inspector can not correctly analyze the nested parallel for, and report a false positive.
*/

#include <stdio.h>


int main(int argh, char* argv[]){
  int i,j,k,m;
  int nthreads = 1;
  double u[12][12][12][5];
  double tmp1,tmp2;
  double fjac[12][12][12][5][5];

  /*initial m */
  for (i = 1; i < 12-1; i++) {
    for (j = 1; j < 12-1; j++) {
      for (k = 0; k < 12; k++){
        for (m = 0; m < 5; m++){
          u[i][j][k][m] = 2.5;
        }
      }
    }
  }
  #pragma omp parallel
  {
  #pragma omp for
  for (i = 1; i < 12-1; i++) {
    for (j = 1; j < 12-1; j++) {
      for (k = 0; k < 12; k++) {
          tmp1 = 1.0 / u[i][j][k][0];
          tmp2 = tmp1 * tmp1;
          
          fjac[i][j][k][0][0] = 0.0;
          fjac[i][j][k][0][1] = 0.0;
          fjac[i][j][k][0][2] = 0.0;
          fjac[i][j][k][0][3] = 1.0;
          fjac[i][j][k][0][4] = 0.0;

          fjac[i][j][k][1][0] = - ( u[i][j][k][1]*u[i][j][k][3] ) * tmp2;
          fjac[i][j][k][1][1] = u[i][j][k][3] * tmp1;
          fjac[i][j][k][1][2] = 0.0;
          fjac[i][j][k][1][3] = u[i][j][k][1] * tmp1;
          fjac[i][j][k][1][4] = 0.0;

          fjac[i][j][k][2][0] = - ( u[i][j][k][2]*u[i][j][k][3] ) * tmp2;
          fjac[i][j][k][2][1] = 0.0;
          fjac[i][j][k][2][2] = u[i][j][k][3] * tmp1;
          fjac[i][j][k][2][3] = u[i][j][k][2] * tmp1;
          fjac[i][j][k][2][4] = 0.0;

          fjac[i][j][k][3][0] = - (u[i][j][k][3]*u[i][j][k][3] * tmp2 ) + 0.50 * ( (  u[i][j][k][1] * u[i][j][k][1] + u[i][j][k][2] * u[i][j][k][2] + u[i][j][k][3] * u[i][j][k][3] ) * tmp2 );
      }
    }
  }
  }
  return 0;
}
