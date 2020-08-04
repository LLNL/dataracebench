!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!One dimension array computation with a vectorization directive. No data race pairs.

program DRB070_simd1_orig_no
    use omp_lib
    implicit none

    integer :: len, i
    integer, dimension(:), allocatable :: a, b, c
    len = 100
    allocate (a(len))
    allocate (b(len))
    allocate (c(len))

    !$omp simd
    do i = 1, len
        a(i) = b(i) + c(i)
    end do
    !$omp end simd

    deallocate(a,b,c)
end program
