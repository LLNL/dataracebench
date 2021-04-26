!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This is a program based on a test contributed by Yizi Gu@Rice Univ.
! * Missing the ordered clause
! * Data race pair: x@21:9:W vs. x@21:9:W


program DRB109_orderedmissing_orig_yes
    use omp_lib
    implicit none

    integer x,i

    !$omp parallel do ordered
    do i = 1, 100
        x = x+1
    end do
    !$omp end parallel do

    print*,'x =',x

end program
