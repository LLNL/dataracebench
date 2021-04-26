!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Data race pair: a[i]@24:9:W vs. a[0]@24:16:R

program DRB039_truedepsingleelement_orig_yes
    use omp_lib
    implicit none

    integer :: len, i
    integer, dimension(:), allocatable :: a

    len = 1000
    allocate (a(len))

    a(1) = 2

    !$omp parallel do
    do i = 1, len
        a(i) = a(i)+a(1)
    end do
    !$omp end parallel do

    print 100, a(500)
    100 format ('a(500) =',i3)

    deallocate(a)
end program
