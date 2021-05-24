!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Only the outmost loop can be parallelized in this program.
!The inner loop has true dependence.
!Data race pair: b[i][j]@29:13:W vs. b[i][j-1]@29:22:R


program DRB037_truedepseconddimension_orig_yes
    use omp_lib
    implicit none

    integer i, j, n, m, len
    real, dimension(:,:), allocatable :: b

    len = 1000
    n = len
    m = len

    allocate (b(len,len))

    do i = 1, n
        !$omp parallel do
        do j = 2, m
            b(i,j) = b(i,j-1)
        end do
        !$omp end parallel do
    end do

    print 100, b(500,500)
    100 format ('b(500,500) =', F20.6)

    deallocate(b)
end program
