!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A linear expression is used as array subscription.
!Data race pair: a[2*i]@27:9:W vs. a[i]@27:18:R

program DRB033_truedeplinear_orig_yes
    use omp_lib
    implicit none

    integer :: i, len
    integer, dimension(:), allocatable :: a

    len = 2000
    allocate (a(len))

    do i = 1, len
        a(i) = i
    end do

    !$omp parallel do
    do i = 1, 1000
        a(2*i) = a(i) + 1
    end do
    !$omp end parallel do

    print 100, a(1002)
    100 format ('a(1002) =',i3)

    deallocate(a)
end program
