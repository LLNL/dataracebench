!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Concurrent access of var@22:5 in an intra region. Missing Lock leads to intra region data race.
!Data Race pairs, var@22:13:W vs. var@22:13:W

program DRB153_missinglock2_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp target map(tofrom:var) device(0)
    !$omp teams num_teams(1)
        !$omp distribute parallel do
        do i = 1, 100
            var = var + 1
        end do
        !$omp end distribute parallel do
    !$omp end teams
    !$omp end target

    print*, var
end program
