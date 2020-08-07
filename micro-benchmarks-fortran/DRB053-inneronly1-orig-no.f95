!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Example with loop-carried data dependence at the outer level loop.
!But the inner level loop can be parallelized.


program DRB053_inneronly1_orig_no
    use omp_lib
    implicit none

    integer :: i, j

    real, dimension(:,:), allocatable :: a
    allocate (a(20,20))

    do i = 1, 20
        do j = 1, 20
            a(i,j) = 0.0
        end do
    end do

    do i = 1, 19
    !$omp parallel do
        do j = 1, 20
            a(i,j) = a(i,j)+a(i+1,j)
        end do
    !$omp end parallel do
    end do

    deallocate(a)
end program
