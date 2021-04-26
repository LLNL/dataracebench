!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two tasks without depend clause to protect data writes.
!i is shared for two tasks based on implicit data-sharing attribute rules.
!Data race pair: i@22:5:W vs. i@25:5:W

program DRB027_taskdependmissing_orig_yes
    use omp_lib
    implicit none

    integer :: i
    i=0

    !$omp parallel
    !$omp single
    !$omp task
    i = 1
    !$omp end task
    !$omp task
    i = 2
    !$omp end task
    !$omp end single
    !$omp end parallel

    print 100, i
    100 format ("i=",i3)

end program
