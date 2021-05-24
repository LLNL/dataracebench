!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The assignment to a@21:9 is  not synchronized with the update of a@29:11 as a result of the
!reduction computation in the for loop.
!Data Race pair: a@21:9:W vs. a@24:30:W


program DRB140_reduction_barrier_orig_yes
    use omp_lib
    implicit none

    integer :: a, i

    !$omp parallel shared(a) private(i)
        !$omp master
        a = 0
        !$omp end master

        !$omp do reduction(+:a)
        do i = 1, 10
            a = a+i
        end do
        !$omp end do

        !$omp single
        print*, "Sum is ", A
        !$omp end single

    !$omp end parallel
end program
