!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Reduction clause at line 23:34 will ensure there is no data race in var@27:13. No Data Race.

program DRB162_nolocksimd_orig_gpu_no
    use omp_lib
    implicit none

    integer :: var(8)
    integer :: i,j

    do i = 1, 8
        var(i) = 0
    end do

    !$omp target map(tofrom:var) device(0)
    !$omp teams num_teams(1) thread_limit(1048)
    !$omp distribute parallel do reduction(+:var)
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

    do i = 1, 8
        if (var(i) /= 20) then
            print*,var(i)
        end if
    end do

end program
