!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The workshare construct is only available in Fortran. The workshare spreads work across the threads 
!executing the parallel. There is an implicit barrier. No data race. 


program DRB170_workshare_orig_no
    use omp_lib
    implicit none
 
    integer :: AA, BB, CC, res
  
    BB = 1
    CC = 2

    !$omp parallel
        !$omp workshare
        AA = BB
        AA = AA+CC
        !$omp end workshare 
    
        !$omp workshare
        res = AA*2
        !$omp end workshare
    !$omp end parallel

    if (res /= 6) then 
        print*,res
    end if
end program
