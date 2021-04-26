!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation using loops: missing private(j).
!References to j in the loop cause data races.
!Data race pairs (we allow multiple ones to preserve the pattern):
!  Write_set = {j@28:12} (implicit step by +1)
!  Read_set = {j@29:17, j@29:26, j@28:12} (implicit step by +1)
!  Any pair from Write_set vs. Write_set  and Write_set vs. Read_set is a data race pair.


program DRB073_doall2_orig_yes
    use omp_lib
    implicit none

    integer :: i, j, len
    integer, dimension(:,:), allocatable :: a
    len = 100

    allocate (a(len,len))

    !$omp parallel do
    do i = 1, 100
        do j = 1, 100
            a(i,j) = a(i,j)+1
        end do
    end do
    !$omp end parallel do


    deallocate(a)
end program
