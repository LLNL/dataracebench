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
#define min(x, y) (((x) < (y)) ? (x) : (y))

/*
use of omp target + teams + distribute + parallel for
*/
int main(int argc, char* argv[])
{
  int i, i2;
  int len = 2560;
  double sum =0.0, sum2=0.0;
  double a[len], b[len];
  /*Initialize with some values*/
  for (i=0; i<len; i++)
  {
    a[i]= ((double)i)/2.0;
    b[i]= ((double)i)/3.0;
  }

#pragma omp target map(to: a[0:len], b[0:len]) map(tofrom: sum)
#pragma omp teams num_teams(10) thread_limit(256) reduction (+:sum) 
#pragma omp distribute
  for (i2=0; i2< len; i2+=256)  
#pragma omp parallel for reduction (+:sum)
    for (i=i2;i< min(i2+256, len); i++)
      sum += a[i]*b[i];

/* CPU reference computation */  
#pragma omp parallel for reduction (+:sum2)
    for (i=0;i< len; i++)
      sum2 += a[i]*b[i];
  printf ("sum=%f sum2=%f\n", sum, sum2);
  return 0;
}
