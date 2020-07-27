!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!!This example is referred from OpenMP Application Programming Interface 5.0, example tasking.7.c
!!A task switch may occur at a task scheduling point. A single thread may execute both of the
!!task regions that modify tp. The parts of these task regions in which tp is modified may be
!!executed in any order so the resulting value of var can be either 1 or 2.
!!There is a  Race pair var@24:13 and var@24:13 but no data race.

module DRB127
    integer :: tp, var
    !$omp threadprivate(tp)
contains
    subroutine foo
        !$omp task
            !$omp task
            tp = 1
                !$omp task
                !$omp end task
            var = tp                ! value of var can be 1 or 2
            !$omp end task
            tp = 2
        !$omp end task
    end subroutine
end module

program DRB127_tasking_threadprivate1_orig_no
    use omp_lib
    use DRB127
    implicit none

    call foo()

end program
