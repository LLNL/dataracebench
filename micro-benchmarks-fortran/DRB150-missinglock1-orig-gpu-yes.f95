!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The distribute parallel do directive at line 22 will execute loop using multiple teams.
!The loop iterations are distributed across the teams in chunks in round robin fashion.
!The omp lock is only guaranteed for a contention group, i.e, within a team.
!Data Race Pair, var@25:9:W vs. var@25:9:W

program DRB150_missinglock1_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var, i
    integer (kind=omp_lock_kind) :: lck
    call omp_init_lock (lck)

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do
    do i = 1, 10
        call omp_set_lock(lck)
        var = var+1
        call omp_unset_lock(lck)
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    call omp_destroy_lock(lck)

    print*, var
end program
