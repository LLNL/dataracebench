!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The workshare construct is only available in Fortran. The workshare spreads work across the threads 
!executing the parallel. There is an implicit barrier. The nowait nullifies this barrier and hence
!there is a race at line:29 due to nowait at line:26. Data Race Pairs, AA@25:9:W vs. AA@29:15:R


program DRB169_workshare_orig_yes 
    use omp_lib
    implicit none
 
    integer :: AA, BB, CC, res
  
    BB = 1
    CC = 2

    !$omp parallel
        !$omp workshare
        AA = BB
        AA = AA+CC
        !$omp end workshare nowait
    
        !$omp workshare
        res = AA*2
        !$omp end workshare
    !$omp end parallel

    if (res /= 6) then 
        print*,res
    end if
end program
