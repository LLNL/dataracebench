!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Concurrent access of var@23 in an intra region. Lock ensures that there is no data race.

program DRB152_missinglock2_orig_gpu_no
    use omp_lib
    implicit none

    integer (kind=omp_lock_kind) :: lck
    integer :: var, i
    var = 0

    call omp_init_lock (lck)

    !$omp target map(tofrom:var) device(0)
    !$omp teams num_teams(1)
    !$omp distribute parallel do
    do i = 1, 100
        call omp_set_lock(lck)
        var = var+1
        call omp_unset_lock(lck)
    end do
    !$omp end distribute parallel do
    !$omp end teams
    !$omp end target
end program
