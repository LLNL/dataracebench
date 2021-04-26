!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Concurrent access of var@30:13 without acquiring locks causes atomicity violation. Data race present.
!Data Race Pairs, var@30:13:W vs. var@30:22:R

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
    !$omp teams distribute parallel do
    do i = 1, 20
        !$omp simd
        do j = 1, 16
            var(j) = var(j)+1
        end do
        !$omp end simd
    end do
    !$omp end teams distribute parallel do
    !$omp end target

    print*,var(16)

end program
