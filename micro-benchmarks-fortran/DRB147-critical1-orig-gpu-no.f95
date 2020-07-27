!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Concurrent access on same variable var@23 and var@25 leads to the race condition if two different
!locks are used. This is the reason here we have used the atomic directive to ensure that addition
!and subtraction are not interleaved. No data race pairs.

program DRB147_critical1_orig_gpu_no
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do
        do i = 0, 100
            !$omp atomic
            var = var+1
            !$omp atomic
            var = var-2
        end do
    !$omp end teams distribute parallel do
    !$omp end target

    print*, var
end program
