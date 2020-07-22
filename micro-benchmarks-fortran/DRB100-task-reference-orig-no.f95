!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

! * Cover the implicitly determined rule: In an orphaned task generating construct,
! * formal arguments passed by reference are firstprivate.
! * This requires OpenMP 4.5 to work.
! * Earlier OpenMP does not allow a reference type for a variable within firstprivate().
! * No data race pairs.


module DRB100
    implicit none
    integer, dimension(:), allocatable :: a
contains
    subroutine gen_task(i)
        use omp_lib
        implicit none
        integer :: i
        !$omp task
        a(i) = i+1
        !$omp end task
    end subroutine
end module

program DRB100_task_reference_orig_no
    use omp_lib
    use DRB100
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
