!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!!The scheduling constraints prohibit a thread in the team from executing
!!a new task that modifies tp while another such task region tied to
!!the same thread is suspended. Therefore, the value written will
!!persist across the task scheduling point.
!!No Data Race

module DRB128
    integer :: tp, var
    !$omp threadprivate(tp)
contains
    subroutine foo
        !$omp task
            !$omp task
            tp = 1
                !$omp task
                !$omp end task
            var = tp
            !$omp end task
        !$omp end task
    end subroutine
end module

program DRB128_tasking_threadprivate2_orig_no
    use omp_lib
    use DRB128
    implicit none

    call foo()
    print*,var
end program
