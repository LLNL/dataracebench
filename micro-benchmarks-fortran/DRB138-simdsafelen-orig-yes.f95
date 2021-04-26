!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The safelen(2) clause safelen(2)@22:16 guarantees that the vector code is safe for vectors up to 2 (inclusive).
!In the loop, m can be 2 or more for the correct execution. If the value of m is less than 2,
!the behavior is undefined. Data Race Pair: b[i]@24:9:W vs. b[i-m]@24:16:R

program DRB137_simdsafelen_orig_no
    use omp_lib
    implicit none

    integer :: i, m, n
    real :: b(4)

    m = 1
    n = 4

    !$omp simd safelen(2)
    do i = m+1, n
        b(i) = b(i-m) - 1.0
    end do

    print*, b(3)
end program
