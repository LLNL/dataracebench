/*
Copyright (c) 2017, Lawrence Livermore National Security, LLC.
Produced at the Lawrence Livermore National Laboratory
Written by Chunhua Liao, Pei-Hung Lin, Joshua Asplund,
Markus Schordan, and Ian Karlin
(email: liao6@llnl.gov, lin32@llnl.gov, asplund1@llnl.gov,
schordan1@llnl.gov, karlin1@llnl.gov)
LLNL-CODE-732144
All rights reserved.

This file is part of DataRaceBench. For details, see
https://github.com/LLNL/dataracebench. Please also see the LICENSE file
for our additional BSD notice.

Redistribution and use in source and binary forms, with
or without modification, are permitted provided that the following
conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the disclaimer below.

* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the disclaimer (as noted below)
  in the documentation and/or other materials provided with the
  distribution.

* Neither the name of the LLNS/LLNL nor the names of its contributors
  may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL LAWRENCE LIVERMORE NATIONAL
SECURITY, LLC, THE U.S. DEPARTMENT OF ENERGY OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
*/
#include <stdio.h>
/* This is a program based on a test contributed by Yizi Gu@Rice Univ.
 * Classic Fibonacci calculation using task but missing taskwait. 
 * Data races pairs: i@61:5 vs i@65:12
 *                   j@63:5 vs j@65:14
 * */
unsigned int input = 10;
int fib(unsigned int n)
{
  if (n<2)
    return n;
  else
  {
    int i, j;
#pragma omp task shared(i)
    i=fib(n-1);
#pragma omp task shared(j)
    j=fib(n-2);

    int res= i+j; 
/* We move the original taskwait to a location after i+j to 
 * simulate the missing taskwait mistake.
 * Directly removing the taskwait may cause a child task to write to i or j
 * within the stack of a parent task which may already be gone, causing seg fault.
 * This change is suggested by Joachim Protze @RWTH-Aachen. 
 * */
#pragma omp taskwait
    return res;
  }
}
int main()
{
  int result = 0;
#pragma omp parallel
  {
   #pragma omp single
    {
      result = fib(input);
    }
  }
  printf ("Fib(%d)=%d (correct answer should be 55)\n", input, result);
  return 0;
}
