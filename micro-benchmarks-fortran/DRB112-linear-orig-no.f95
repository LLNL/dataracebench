!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!omp for loop is allowed to use the linear clause, an OpenMP 4.5 addition. No data race pairs.

program DRB112_linear_orig_no
    use omp_lib
    implicit none

    integer len, i, j
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: a,b,c

    len = 100
    i = 0
    j = 0

    allocate (a(len))
    allocate (b(len))
    allocate (c(len))

    do i = 1, len
        a(i) = (real(i,dp))/2.0
        b(i) = (real(i,dp))/3.0
        c(i) = (real(i,dp))/7.0
    end do

    !$omp parallel do linear(j)
    do i = 1, len
        c(j) = c(j)+a(i)*b(i)
        j = j+1
    end do
    !$omp end parallel do

    !print*,'c(50) =',c(50)

    if(allocated(a))deallocate(a)
    if(allocated(b))deallocate(b)
end program
