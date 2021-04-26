!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The loop in this example cannot be parallelized.
!
!This pattern has two pair of dependencies:
!1. loop carried output dependence
! x = .. :
!
!2. loop carried true dependence due to:
!.. = x;
! x = ..;
!Data race pairs: we allow two pairs to preserve the original code pattern.
! 1. x@48:16:R vs. x@49:9:W
! 2. x@49:9:W vs. x@49:9:W


module globalArray
    implicit none
    integer, dimension(:), allocatable :: a
    contains
    subroutine useGlobalArray(len)
        integer :: len
        len = 100
        allocate (a(100))
    end subroutine useGlobalArray
end module globalArray

program DRB016_outputdep_orig_yes
    use omp_lib
    use globalArray

    implicit none

    integer len, i, x

    len = 100
    x = 10

    call useGlobalArray(len)

    !$omp parallel do
    do i = 1, len
        a(i) = x
        x = i
    end do
    !$omp end parallel do

    write(*,*) "x =",x
end program

