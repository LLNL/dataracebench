/* Race because the write to s is not protected by atomic */
#include <stdio.h>
int main() {
  int x=0, s=0;
#pragma omp parallel sections shared(x,s) num_threads(2)
  {
#pragma omp section
    {
      x=1;
      s=1;
    }
#pragma omp section
    {
      int done = 0;
      while (!done) {
#pragma omp atomic read seq_cst
	done = s;
      }
      x=2;
    }
  }
  printf("%d\n", x);
}
