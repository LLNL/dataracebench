!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is referred from DRACC by Adrian Schmitz et al.
!The condition check at line 23:17 is critical and increment at line number 25 is atomic for the variable
!var@28:17. Therefore, there is a possible Data Race pair var@23:17 and var@23:17.

program DRB144_atomiccritical_orig_gpu_yes
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do
        do i = 1, 200
            !$omp critical
            if (var<101) then
                !$omp atomic
                var = var+1
                !$omp end atomic
            end if
            !$omp end critical
        end do
    !$omp end teams distribute parallel do
    !$omp end target

    print*,var
end program
