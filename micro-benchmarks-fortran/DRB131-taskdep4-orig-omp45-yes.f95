!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!There is no completion restraint on the second child task. Hence, immediately after the first
!taskwait it is unsafe to access the y variable since the second child task may still be
!executing.
!Data Race at y@34:8:W vs. y@41:23:R

program DRB131_taskdep4_orig_yes_omp_45
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

        !$omp task depend(in: x) if(.FALSE.)    !!1st taskwait
        !$omp end task

        print*, "x=", x
        print*, "y=", y

        !$omp taskwait                          !!2nd taskwait
    end subroutine foo
end program
