!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Example use of firstprivate(). No data race pairs.

module DRB048
    use omp_lib
    implicit none

    integer, dimension(:), allocatable :: a
contains
    subroutine foo(a,n,g)
        use omp_lib
        implicit none
        integer :: i
        integer, value :: n, g
        integer, dimension(:), allocatable :: a

        !$omp parallel do firstprivate(g)
        do i = 1, n
            a(i)=a(i)+g
        end do
        !$omp end parallel do
    end subroutine
end module

program DRB048_firstprivate_orig_no
    use omp_lib
    use DRB048
    implicit none

    allocate (a(100))
    call foo(a, 100, 7)
    print*,a(50)
end program


