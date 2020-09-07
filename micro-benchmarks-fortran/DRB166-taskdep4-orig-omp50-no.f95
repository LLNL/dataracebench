!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The second taskwait ensures that the second child task has completed; hence it is safe to access
!the y variable in the following print statement.

program DRB166_taskdep4_orig_no_omp50
    use omp_lib
    implicit none

    !$omp parallel
    !$omp single
    call foo()
    !$omp end single
    !$omp end parallel
contains
    subroutine foo()
        implicit none
        integer :: x, y
        x = 0
        y = 2

        !$omp task depend(inout: x) shared(x)
        x = x+1                                 !!1st Child Task
        !$omp end task

        !$omp task shared(y)
        y = y-1                                 !!2nd child task
        !$omp end task

        !$omp taskwait depend(in: x)            !!1st taskwait

        print*, "x=", x

        !$omp taskwait                          !!2nd taskwait

        print*, "y=", y

    end subroutine
end program
