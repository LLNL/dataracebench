!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The outmost loop is parallelized.
!But the inner level loop has out of bound access for b[i][j] when j equals to 0.
!This will case memory access of a previous row's last element.
!
!For example, an array of 4x4:
!    j=1 2 3 4
! i=1  x x x x
!   2  x x x x
!   3  x x x x
!   4  x x x x
!  outer loop: i=1,
!  inner loop: j=2
!  array element accessed b[i][j-1] becomes b[0][1], which in turn is b[4][1]
!  due to linearized column-major storage of the 2-D array.
!  This causes loop-carried data dependence between i=1 and i=4.
!
!Data race pair: b[i][j]@41 vs. b[i-1][j]@41.

program DRB014_outofbounds_orig_yes
    use omp_lib
    implicit none

    integer :: i, j, n, m
    real, dimension (:,:), allocatable :: b

    n = 100
    m = 100

    allocate (b(n,m))

    !$omp parallel do private(j)
    do j = 2, n
        do i = 1, m
            b(i,j) = b(i-1,j)
        end do
    end do
    !$omp end parallel do
    print*,"b(50,50)=",b(50,50)

    deallocate(b)
end program
