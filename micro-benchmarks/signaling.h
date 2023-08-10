#if defined(WIN32) || defined(_WIN32)
#include <windows.h>
#define delay() Sleep(1);
#else
#include <unistd.h>
#define delay(t) usleep(t);
#endif

// These functions are used to provide a signal-wait mechanism to enforce expected scheduling for the test cases.
// Conditional variable (s) needs to be shared! Initialize to 0

#define SIGNAL(s) atomic_signal(&s)
void atomic_signal(int* s)
{
  #pragma omp atomic
  (*s)++;
}

#define WAIT(s,v) atomic_wait(&s,v)
// wait for s >= v
void atomic_wait(int *s, int v)
{
  int wait=0;
  do{
    delay(100);
    #pragma omp atomic read
	  wait = (*s);
  }while(wait<v);
}
