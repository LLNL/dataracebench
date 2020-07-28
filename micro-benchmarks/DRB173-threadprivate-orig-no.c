/**
 * EP.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 EP suit.
 * Intel Inspector can not correctly analysis the threadprivate, and report a false postive.
*/

#include <stdio.h>

static double x[20];
#pragma omp threadprivate(x)


int main(int argh, char* argv[]){
  int i,m,n;
  double j,k;
  int p[12][12][12];

#pragma omp parallel for default(shared) private(i,j,k,m,n)
    for (i = 0; i < 20; i++){
        x[i] = -1.0e99;
        j = x[0];
        k = i +0.05;
    }
    /*
#pragma omp for nowait
    for (i = 1; i < 12-1; i++) {
      for (m = 1; m < 12-1; j++) {
          for (n = 0; n < 12; k++){
                 p[i][m][n] = 2;
        }
      }
      }
    for (m=1; m<5; m++){
      #pragma omp for
       for (i=0;i<10;i++){
           for (n=0; n<10; n++){
               p[m][i][n] += i;
               
           }
           
       }
      #pragma omp barrier
    } Tsan didn't report the code cazue it fail, only intel,romp archer has same issue for this code */
}
