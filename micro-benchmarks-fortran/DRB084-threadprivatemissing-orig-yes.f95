!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A file-scope variable used within a function called by a parallel region.
!No threadprivate is used to avoid data races.
!
!Data race pairs  sum@39:13:W vs. sum@39:19:R
!                 sum@39:13:W vs. sum@39:13:W

module DRB084
    implicit none
    integer (kind=8) :: sum0, sum1
contains
    subroutine foo(i)
        integer (kind=8) :: i
        sum0=sum0+i
    end subroutine
end module

program DRB084_threadprivatemissing_orig_yes
    use omp_lib
    use DRB084
    implicit none

    integer (kind=8) :: i, sum
    sum = 0

    !$omp parallel
        !$omp do
            do i = 1, 1001
                call foo(i)
            end do
        !$omp end do
        !$omp critical
            sum = sum + sum0
        !$omp end critical
    !$omp end parallel

    do i = 1, 1001
        sum1 = sum1+i
    end do

    print*,'sum = ',sum,'sum1 =',sum1
end program
