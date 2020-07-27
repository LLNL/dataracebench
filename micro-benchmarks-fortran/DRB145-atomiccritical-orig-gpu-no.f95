!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The increment operation at line@22:17 is team specific as each team work on their individual var.
!No Data Race Pair

program DRB145_atomiccritical_orig_gpu_no
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do reduction(+:var)
        do i = 1, 200
            if (var<101) then
                var = var+1
            end if
        end do
    !$omp end teams distribute parallel do
    !$omp end target

end program
