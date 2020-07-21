!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This benchmark is extracted from flush_nolist.1c of OpenMP
!Application Programming Interface Examples Version 4.5.0 .
!
!We privatize variable i to fix data races in the original example.
!Once i is privatized, flush is no longer needed. No data race pairs.

module DRB076
    use omp_lib
    implicit none
contains
    subroutine f1(q)
        integer :: q
        q = 1
    end subroutine
end module

program DRB076_flush_orig_no
    use omp_lib
    use DRB076
    implicit none

    integer :: i, sum
    i = 0
    sum = 0

    !$omp parallel reduction(+:sum) num_threads(10) private(i)
    call f1(i)
    sum = sum + i
    !$omp end parallel

    if (sum /= 10) then
        print*,'sum =',sum
    end if
end program
