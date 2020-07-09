/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
 * A task switch may occur at a task scheduling point. A single thread may execute both of the 
 * task regions that modify tp. The parts of these task regions in which tp is modified may be 
 * executed in any order so the resulting value of var can be either 1 or 2.
 * Data Race at line:34
 */


#include <omp.h>
#include <stdio.h>

int tp;
#pragma omp threadprivate(tp)
int var;

int main(){
	#pragma omp task
  {
		#pragma omp task
	  {
		  tp = 1;
			#pragma omp task
			{
			}
			var = tp;
		}
		tp=2;
	}

	if(var==2) printf("%d\n",var);
	
	return 0;
}
