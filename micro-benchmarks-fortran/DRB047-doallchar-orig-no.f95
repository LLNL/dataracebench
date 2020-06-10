!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!One dimension array computation
!with finer granularity than traditional 4 bytes.
!Dynamic tools monitoring 4-bytes elements may wrongfuly report race condition.

program DRB047_doallchar_orig_no
    use omp_lib
    implicit none

    character(len=100), dimension(:), allocatable :: a
    integer :: i

    allocate (a(100))

    !$omp parallel do
    do i = 1, 100
        a(i) = 1 !Error: Cannot convert INTEGER(4) to CHARACTER(1) at (1) //check on this w/ Leo
    end do
    !$omp end parallel do

    print*,'a(i)',a(23)
end program
