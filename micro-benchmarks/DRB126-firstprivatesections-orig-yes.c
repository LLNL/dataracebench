/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
*/

/*
 * This example is based on fpriv_sections.1.c OpenMP Examples 5.0.0
 * The section construct modifies the value of section_count which breaks the independence of the 
 * section constructs. If the same thread executes both the section one will print 1 and the other
 * will print 2. The order is undpecified. 
 * There is data race at line:30 and line:35. It may print 1 or 2. 
 */

#include <omp.h>
#include <stdio.h>

int main(){
	int section_count = 0;
	omp_set_dynamic(0);
	
	#pragma omp parallel
	#pragma omp sections firstprivate( section_count )
	{
		#pragma omp section 
		{	
			section_count++;
			printf("%d\n",section_count);
		}
		#pragma omp section
		{
			section_count++;
			printf("%d\n",section_count);
		}
	}
	return 0;
}
