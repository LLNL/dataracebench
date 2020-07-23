!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!collapse(2) is used to associate two loops with omp for.
!The corresponding loop iteration variables are private. No data race pairs.


module DRB093
    implicit none
    integer, dimension(:,:), allocatable :: a
end module

program DRB093_doall2_collapse_orig_no
    use omp_lib
    use DRB093
    implicit none

    integer :: len, i, j
    len = 100

    allocate (a(len,len))

    !$omp parallel do collapse(2)
    do i = 1, len
        do j = 1, len
            a(i,j) = a(i,j)+1
        end do
    end do
    !$omp end parallel do
end program
