!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!To avoid data race, the initialization of the original list item "a" should complete before any
!update of a as a result of the reduction clause. This can be achieved by adding an explicit
!barrier after the assignment a=0@22:9, or by enclosing the assignment a=0@22:9 in a single directive
!or by initializing a@21:7 before the start of the parallel region. No data race pair


program DRB141_reduction_barrier_orig_no
    use omp_lib
    implicit none

    integer :: a, i

    !$omp parallel shared(a) private(i)
        !$omp master
        a = 0
        !$omp end master
        
        !$omp barrier        

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
