!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This one has data races due to true dependence.
!But data races happen at instruction level, not thread level.
!Data race pair: a[i+1]@32:9:W vs. a[i]@32:18:R

program DRB024_simdtruedep_orig_yes
    use omp_lib
    implicit none

    integer :: i, len
    integer, dimension(:), allocatable :: a
    integer, dimension(:), allocatable :: b

    len = 100

    allocate (a(len))
    allocate (b(len))

    do i = 1, len
        a(i) = i
        b(i) = i+1
    end do

    !$omp simd
    do i = 1, len-1
        a(i+1) = a(i) + b(i)
    end do

    do i = 1, len
        write(6,*) 'Values for i and a(i) are:', i, a(i)
    end do

    deallocate(a,b)
end program
