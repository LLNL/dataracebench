!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Addition of mutexinoutset dependence type on c, will ensure that line d@36:9 assignment will depend
!on task at Line 29 and line 32. They might execute in any order but not at the same time.
!There is no data race.

program DRB135_taskdep_mutexinoutset_orig_no_omp50
    use omp_lib
    implicit none

    integer :: a, b, c, d

    !$omp parallel
    !$omp single
        !$omp task depend(out: c)
        c = 1      ! Task T1
        !$omp end task
        !$omp task depend(out: a)
        a = 2      ! Task T2
        !$omp end task
        !$omp task depend(out: b)
        b = 3      ! Task T3
        !$omp end task
        !$omp task depend(in: a) depend(mutexinoutset: c)
        c = c + a  ! Task T4
        !$omp end task
        !$omp task depend(in: b) depend(mutexinoutset: c)
        c = c + b  ! Task T5
        !$omp end task
        !$omp task depend(in: c)
        d = c      ! Task T6
        !$omp end task
    !$omp end single
    !$omp end parallel

    print *, d
end program
