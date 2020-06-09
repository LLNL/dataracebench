!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Only the outmost loop can be parallelized.
!The inner loop has loop carried true data dependence.
!However, the loop is not parallelized so no race condition.

program DRB064_outeronly2_orig_no
    use omp_lib
    implicit none

    call foo()
contains
    subroutine foo()
        integer :: i, j, n, m, len
        real, dimension(:,:), allocatable :: b

        len = 100
        allocate (b(len,len))
        n = len
        m = len

        !$omp parallel do private(j)
        do i = 1, n
            do j = 2, m
                b(i,j) = b(i,j-1)
            end do
        end do
        !$omp end parallel do
    end subroutine foo
end program
