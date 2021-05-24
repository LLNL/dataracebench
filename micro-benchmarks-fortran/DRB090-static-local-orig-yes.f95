!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!For a variable declared in a scope inside an OpenMP construct:
!* private if the variable has an automatic storage duration
!* shared if the variable has a static storage duration.
!
!Dependence pairs:
!   tmp@38:13:W vs. tmp@38:13:W
!   tmp@38:13:W vs. tmp@39:20:R


program DRB090_static_local_orig_yes
    use omp_lib
    implicit none

    integer :: i, len
    integer, dimension(:), allocatable :: a, b
    integer, save :: tmp
    integer :: tmp2

    len = 100
    allocate (a(len))
    allocate (b(len))

    do i = 1, len
        a(i) = i
        b(i) = i
    end do

    !$omp parallel
        !$omp do
        do i = 1, len
            tmp = a(i)+i
            a(i) = tmp
        end do
        !$omp end do
    !$omp end parallel

    !$omp parallel
        !$omp do
        do i = 1, len
            tmp2 = b(i)+i
            b(i) = tmp2
        end do
        !$omp end do
    !$omp end parallel

    print 100, a(50), b(50)
    100 format (i3,3x,i3)

    deallocate(a,b)

end program
