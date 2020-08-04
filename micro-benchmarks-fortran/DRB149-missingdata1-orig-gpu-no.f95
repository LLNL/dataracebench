!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Classic i-k-j matrix multiplication. No data race pairs.

program DRB149_missingdata1_orig_gpu_no
    use omp_lib
    implicit none

    integer :: len, i, j
    integer, dimension(:), allocatable :: a, b, c

    len = 100

    allocate (a(len))
    allocate (b(len+len*len))
    allocate (c(len))

    do i = 1, len
        do j = 1, len
            b(j+i*len)=1
        end do
        a(i) = 1
        c(i) = 0
    end do

    !$omp target map(to:a,b) map(tofrom:c) device(0)
    !$omp teams distribute parallel do
    do i = 1, len
        do j = 1, len
            c(i) = c(i)+a(j)*b(j+i*len)
        end do
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    do i = 1, len
        if (c(i)/=len) then
            print*, c(i)
        end if
    end do

    deallocate(a,b,c)
end program
