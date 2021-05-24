!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Race condition due to anti-dependence within a loop offloaded to accelerators.
!Data race pair: a[i]@29:13:W vs. a[i+1]@29:20:R

program DRB026_targetparallelfor_orig_yes
    use omp_lib
    implicit none

    integer :: i, len
    integer, dimension(:), allocatable :: a

    len = 1000

    allocate (a(len))

    do i = 1, len
        a(i) = i
    end do

    !$omp target map(a)
        !$omp parallel do
        do i = 1, len-1
            a(i) = a(i+1) + 1
        end do
        !$omp end parallel do
    !$omp end target

    do i = 1, len
        write(6,*) 'Values for i and a(i) are:', i, a(i)
    end do

    deallocate(a)
end program
