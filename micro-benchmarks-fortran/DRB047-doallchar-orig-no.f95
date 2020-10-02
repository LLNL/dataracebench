!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!One dimension array computation
!with finer granularity than traditional 4 bytes.
!There is no data race pair.

program DRB047_doallchar_orig_no
    use omp_lib
    implicit none

    character(len=100), dimension(:), allocatable :: a
    character(50) :: str
    integer :: i

    allocate (a(100))

    !$omp parallel do private(str)
    do i = 1, 100
        write( str, '(i10)' )  i
        a(i) = str
    end do
    !$omp end parallel do

    print*,'a(i)',a(23)
end program
