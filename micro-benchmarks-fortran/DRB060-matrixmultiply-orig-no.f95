!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Classic i-k-j matrix multiplication. No data race pairs.


program DRB060_matrixmultiply_orig_no
    use omp_lib
    implicit none

    integer :: N,M,K, len, i, j, l
    real, dimension(:,:), allocatable :: a, b, c

    len = 100
    N=len
    M=len
    K=len

    allocate (a(N,M))
    allocate (b(M,K))
    allocate (c(K,N))

    !$omp parallel do private(j, l)
    do i = 1, N
        do l = 1, K
            do j = 1, M
                c(i,j) = c(i,j)+a(i,l)*b(l,j)
            end do
        end do
    end do
    !$omp end parallel do

    deallocate(a,b,c)
end program
