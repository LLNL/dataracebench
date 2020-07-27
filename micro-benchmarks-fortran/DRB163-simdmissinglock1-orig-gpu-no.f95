!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Concurrent access of var@26:13 has no atomicity violation. No data race present.

module DRB163
    integer :: var(16)
    integer :: i, j
end module

program DRB163_simdmissinglock1_orig_gpu_no
    use omp_lib
    use DRB163
    implicit none

    do i = 1, 16
        var(i) = 0
    end do

    !$omp target map(tofrom:var) device(0)
    !$omp teams distribute parallel do reduction(+:var)
    do i = 1, 20
        !$omp simd
        do j = 1, 16
            var(j) = var(j)+1
        end do
        !$omp end simd
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    do i = 1, 16
        if (var(i) /= 20) then
            print*, var(i), i
        end if
    end do

end program
