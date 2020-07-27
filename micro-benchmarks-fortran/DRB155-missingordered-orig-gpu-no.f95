!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!By utilizing the ordered construct @23 the execution will be sequentially consistent.
!No Data Race Pair.

program DRB155_missingordered_orig_gpu_no
    use omp_lib
    implicit none

    integer :: var(100)
    integer :: i

    do i = 1, 100
        var(i) = 1
    end do

    !$omp target map(tofrom:var) device(0)
    !$omp parallel do ordered
    do i = 2, 100
        !$omp ordered
        var(i) = var(i-1)+1
        !$omp end ordered
    end do
    !$omp end parallel do
    !$omp end target

    do i = 1, 100
        if (var(i)/=i) then
            print*,"Data Race Present"
        end if
    end do

end program
