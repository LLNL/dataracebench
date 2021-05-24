!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This loop has loop-carried output-dependence due to x=... at line 21.
!The problem can be solved by using lastprivate(x).
!Data race pair: x@21:9:W vs. x@21:9:W

program DRB009_lastprivatemissing_orig_yes
    use omp_lib
    implicit none

    integer :: i, x, len
    len = 10000

    !$omp parallel do private(i)
    do i = 0, len
        x = i
    end do
    !$omp end parallel do

    write(*,*) 'x =', x
end program
