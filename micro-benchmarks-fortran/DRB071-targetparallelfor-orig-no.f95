!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!use of omp target: len is not mapped. It should be firstprivate within target. No data race pairs.

program DRB071_targetparallelfor_orig_no
    use omp_lib
    implicit none

    integer :: i, len
    integer, dimension(:), allocatable :: a

    len = 1000
    
    allocate(a(len))

    do i = 1, len
        a(i) = i
    end do

    !$omp target map(a(1:len))
    !$omp parallel do
    do i = 1, len
        a(i) = a(i)+1
    end do
    !$omp end target

    deallocate(a)
end program
