!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is from DRACC by Adrian Schmitz et al.
!Concurrent access on a counter with no lock with simd. Atomicity Violation. Intra Region.
!Data Race Pairs: var@29:13:W vs. var@29:13:W

program DRB161_nolocksimd_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var(8)
    integer :: i, j

    do i = 1, 8
        var(i) = 0
    end do

    !$omp target map(tofrom:var) device(0)
    !$omp teams num_teams(1) thread_limit(1048)
    !$omp distribute parallel do
    do i = 1, 20
        !$omp simd
        do j = 1, 8
            var(j) = var(j)+1
        end do
        !$omp end simd
    end do
    !$omp end distribute parallel do
    !$omp end teams
    !$omp end target

    print*,var(8)
end program
