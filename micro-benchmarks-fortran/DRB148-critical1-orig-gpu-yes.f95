!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Though we have used critical directive to ensure that additions across teams are not overlapped.
!Critical only synchronizes within a team. There is a data race pair.
!Data Race pairs, var@24:9:W vs. var@24:15:R


program DRB148_critical1_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do
    do i = 1, 100
        !$omp critical(addlock)
        var = var+1
        !$omp end critical(addlock)
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    print*,var
end program
