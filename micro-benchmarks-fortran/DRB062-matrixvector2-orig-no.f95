!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Matrix-vector multiplication: inner level parallelization. No data race pairs.

program DRB062_matrixvector2_orig_no
    use omp_lib
    implicit none

    call foo
contains
    subroutine foo()
        integer :: i, j, N
        real :: sum
        real, dimension(:,:), allocatable :: a
        real, dimension(:), allocatable :: v, v_out

        N = 1000
        allocate (a(N,N))
        allocate (v(N))
        allocate (v_out(N))

        do i = 1, N
            sum = 0.0
            !$omp parallel do reduction(+:sum)
            do j = 1, N
                sum = sum + a(i,j)*v(j)
                print*,sum
            end do
            !$omp end parallel do
            v_out(i) = sum
        end do

    end subroutine foo
end program
