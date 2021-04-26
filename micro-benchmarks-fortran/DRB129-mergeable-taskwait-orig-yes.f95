!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Taken from OpenMP Examples 5.0, example tasking.12.c
!The created task will access different instances of the variable x if the task is not merged,
!as x is firstprivate, but it will access the same variable x if the task is merged. It can
!Data Race Pairs, x@22:5:W vs. x@22:5:W
!print two different values for x depending on the decisions taken by the implementation.

program DRB129_mergeable_taskwait_orig_yes
    use omp_lib
    implicit none

    integer :: x
    x = 2

    !$omp task mergeable
    x = x+1
    !$omp end task

    print 100, x
    100 format ('x =',3i8)
end program
