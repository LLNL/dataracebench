!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This is a program based on a test contributed by Yizi Gu@Rice Univ.
!Proper user of ordered directive and clause, no data races


program DRB110_ordered_orig_no
    use omp_lib
    implicit none

    integer x, i
    x=0
    
    !$omp parallel do ordered
    do i = 1, 100
        !$omp ordered
        x = x+1
        !$omp end ordered
    end do
    !$omp end parallel do    

    print*,'x =',x
end program
