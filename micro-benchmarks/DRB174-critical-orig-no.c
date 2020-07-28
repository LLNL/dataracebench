/**
 * FT.C: This file is part of kernel of the NAS Parallel Benchmarks 3.0 FT suit.
 * Intel Inspector can not correctly analysis the nowaite, and report a false postive.
 * Tsan can not correctly analysis the critical, and report a false postive.
*/

#include <stdio.h>

int main(int argh, char* argv[]){
  int i;
  double q[10], qq[10],x[20];

#pragma omp parallel for default(shared) private(i)
  for (i = 0; i < 20; i++) x[i] = -1.0e99;
  for (i = 0; i < 10; i++) qq[i] = 1.0;
  /*initial m */
#pragma omp parallel default(shared)
{
  #pragma omp for nowait //intel
    for (i = 0; i <= 10 - 1; i++) q[i] += qq[i];
  #pragma omp critical //tsan
      {
          q[i] += 1.0;
      }
  #pragma omp barrier
  #pragma omp single
    {
        q[i] += 1.0;
    }

}
}
