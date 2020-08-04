!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!default(none) to enforce explictly list all variables in data-sharing attribute clauses
!default(shared) to cover another option. No data race pairs.


program DRB113_default_orig_no
    use omp_lib
    implicit none

    integer len,i,j
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:,:), allocatable :: a,b

    len = 100

    allocate (a(len, len))
    allocate (b(len, len))

    !$omp parallel do default(none) shared(a) private(i,j)
    do i = 1, 100
        do j = 1, 100
            a(i,j) = a(i,j)+1
        end do
    end do
    !$omp end parallel do

    !$omp parallel do default(shared) private(i,j)
    do i = 1, 100
        do j = 1, 100
            b(i,j) = b(i,j)+1
        end do
    end do
    !$omp end parallel do

    print*,a(50,50),b(50,50)

    deallocate(a,b)
end program
