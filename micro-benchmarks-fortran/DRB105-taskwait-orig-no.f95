!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!* This is a program based on a test contributed by Yizi Gu@Rice Univ.
!* Classic Fibonacci calculation using task+taskwait. No data races.


module DRB105
    implicit none
    integer input
contains
    recursive function fib(n) result(r)
        use omp_lib
        implicit none
        integer :: n, i, j, r

        if (n<2) then
            r = n
        else
            !$omp task shared(i)
            i = fib(n-1)
            !$omp end task
            !$omp task shared(j)
            j = fib(n-2)
            !$omp end task
            !$omp taskwait
            r = i+j
        end if
    end function
end module

program DRB105_taskwait_orig_no
    use omp_lib
    use DRB105
    implicit none

    integer :: result
    input = 30

    !$omp parallel
    !$omp single
    result = fib(input)
    !$omp end single
    !$omp end parallel

    print 100, input, result
    100 format ('Fib for ',3i8,' =',3i8)
end program
