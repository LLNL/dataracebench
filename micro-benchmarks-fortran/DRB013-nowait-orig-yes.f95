!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is extracted from a paper:
!Ma etc. Symbolic Analysis of Concurrency Errors in OpenMP Programs, ICPP 2013
!
!Some threads may finish the for loop early and execute errors = dt[10]+1
!while another thread may still be simultaneously executing
!the for worksharing region by writing to d[9], causing data races.
!
!Data race pair: a[i]@41:21:R vs. a[10]@37:17:W

program DRB013_nowait_orig_yes
    use omp_lib
    implicit none

    integer i, error, len, b
    integer, dimension (:), allocatable :: a

    b = 5
    len = 1000

    allocate (a(len))

    do i = 1, len
        a(i) = i
    end do

    !$omp parallel shared(b, error)
        !$omp parallel
            !$omp do
            do i = 1, len
                a(i) = b + a(i)*5
            end do
            !$omp end do nowait
            !$omp single
            error = a(10) + 1;
            !$omp end single
        !$omp end parallel
    !$omp end parallel

    print*,"error =",error

    deallocate(a)
end program
