!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This benchmark is extracted from flush_nolist.1c of OpenMP Application
!Programming Interface Examples Version 4.5.0 .
!We added one critical section to make it a test with only one pair of data races.
!The data race will not generate wrong result though. So the assertion always passes.
!Data race pair:  i@37:13:W vs. i@38:15:R

module DRB074
    use omp_lib
    implicit none
contains
    subroutine f1(q)
        integer :: q
        !$omp critical
        q = 1
        !$omp end critical
        !$omp flush
    end subroutine
end module

program DRB074_flush_orig_yes
    use omp_lib
    use DRB074
    implicit none

    integer :: i, sum
    i = 0
    sum =  0

    !$omp parallel reduction(+:sum) num_threads(10)
    call f1(i)
    sum = sum+i
    !$omp end parallel

    if (sum /= 10) then
        print*,'sum =',sum
    end if
end program
