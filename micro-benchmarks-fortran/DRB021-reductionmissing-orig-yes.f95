!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A kernel with two level parallelizable loop with reduction:
!if reduction(+:sum) is missing, there is race condition.
!Data race pairs: we allow multiple pairs to preserve the pattern.
!  getSum@37:13:W vs. getSum@37:13:W
!  getSum@37:13:W vs. getSum@37:22:R

program DRB021_reductionmissing_orig_yes
    use omp_lib
    implicit none

    integer :: i, j, len
    real :: temp, getSum
    real, dimension (:,:), allocatable :: u

    len = 100
    getSum = 0.0

    allocate (u(len, len))

    do i = 1, len
        do j = 1, len
            u(i,j) = 0.5
        end do
    end do

    !$omp parallel do private(temp, i, j)
    do i = 1, len
        do j = 1, len
            temp = u(i,j)
            getSum = getSum + temp * temp
        end do
    end do
    !$omp end parallel do

    print*,"sum =", getSum
    deallocate(u)
end program
