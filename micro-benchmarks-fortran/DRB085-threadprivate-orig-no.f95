!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A file-scope variable used within a function called by a parallel region.
!Use threadprivate to avoid data races. No data race pairs.

module DRB085
    implicit none
    integer (kind=8) :: sum0, sum1
!$omp threadprivate(sum0)
contains
    subroutine foo(i)
        integer (kind=8) :: i
        sum0=sum0+i
    end subroutine
end module

program DRB085_threadprivate_orig_no
    use omp_lib
    use DRB085
    implicit none

    integer :: len
    integer (kind=8) :: i, sum
    len = 1000
    sum = 0

    !$omp parallel copyin(sum0)
        !$omp do
        do i = 1, len
            call foo(i)
        end do
        !$omp end do
        !$omp critical
        sum = sum+sum0
        !$omp end critical
    !$omp end parallel

    do i = 1, len
        sum1=sum1+i
    end do

    print*,'sum = ',sum,'sum1 =',sum1
end program
