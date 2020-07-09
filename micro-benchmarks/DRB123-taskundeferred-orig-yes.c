/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
When an if clause is present on a task construct, and the if clause expression evaluates to
false, an undeferred task is generated, and the encountering thread must suspend the current
task region, for which execution cannot be resumed until execution of the structured block
that is associated with the generated task is completed. The use of a variable in an if
clause expression of a task construct causes an implicit reference.

This causes data race at line:33 due to if clause at line:31.
*/

#include <omp.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
  int var = 0;
  int i;

  #pragma omp parallel for shared(var) schedule(static,1)
  for (i = 0; i < 10; i++) {
    #pragma omp task shared(var) if(0)
    {
      var++;
    }
  }

  int error = (var != 10);
  fprintf(stderr, "DONE %d \n",var);
  return error;
}
