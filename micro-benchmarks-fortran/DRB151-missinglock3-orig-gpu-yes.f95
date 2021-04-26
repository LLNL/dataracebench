!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The distribute parallel do directive at line 19 will execute loop using multiple teams.
!The loop iterations are distributed across the teams in chunks in round robin fashion.
!The missing lock enclosing var@21 leads to data race. Data Race Pairs, var@21:9:W vs. var@21:9:W

program DRB151_missinglock3_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var, i

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do
    do i = 1, 100
        var = var+1
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    print*, var
end program
