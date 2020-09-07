!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Arrays passed as function parameters. No data race pairs.


module DRB050
    use omp_lib
    implicit none
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: o1, c
contains
    subroutine foo1(o1,c,len)
        integer, parameter :: dp = kind(1.0d0)
        real(dp), dimension(:), allocatable :: o1, c
        real(dp) :: volnew_o8
        integer :: len, i

        !$omp parallel do private(volnew_o8)
        do i = 1, len
            volnew_o8 = 0.5*c(i)
            o1(i) = volnew_o8
        end do
        !$omp end parallel do
!        print*,o1(50)
    end subroutine
end module

program DRB050_functionparameter_orig_no
    use omp_lib
    use DRB050
    implicit none

    allocate (o1(100))
    allocate (c(100))

    call foo1(o1, c, 100)
end program
