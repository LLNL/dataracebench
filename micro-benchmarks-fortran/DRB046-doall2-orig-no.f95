!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!Only one loop is associated with the omp for construct.
!The inner loop's loop iteration variable needs an explicit private() clause,
!otherwise it will be shared by default. No data race pairs.

program DRB046_doall2_orig_no
    use omp_lib
    implicit none

    integer :: i, j
    integer :: a(100,100)

    !$omp parallel do private(j)
    do i = 1, 100
        do j = 1, 100
            a(i,j) = a(i,j)+1
        end do
    end do
    !$omp end parallel do
end program
