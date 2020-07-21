!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

! * Cover an implicitly determined rule: In a task generating construct,
! * a variable without applicable rules is firstprivate. No data race pairs.


module DRB101
    implicit none
    integer, dimension(:), allocatable :: a
contains
    subroutine gen_task(i)
        use omp_lib
        implicit none
        integer, value :: i
        !$omp task
        a(i) = i+1
        !$omp end task
    end subroutine
end module

program DRB101_task_value_orig_no
    use omp_lib
    use DRB101
    implicit none

    integer :: i
    allocate (a(100))

    !$omp parallel
        !$omp single
        do i = 1, 100
            call gen_task(i)
        end do
        !$omp end single
    !$omp end parallel

    do i = 1, 100
        if (a(i) /= i+1) then
            print*,'warning: a(',i,') =',a(i),' not expected',i+1
        end if
!        print*,a(i),i+1
    end do
end program
