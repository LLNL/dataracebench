!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!No data race. The data environment of the task is created according to the
!data-sharing attribute clauses, here at line 21:27 it is var. Hence, var is
!modified 10 times, resulting to the value 10.

program DRB122_taskundeferred_orig_no
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp parallel sections
    do i = 1, 10
        !$omp task shared(var) if(.FALSE.)
        var = var+1;
        !$omp end task
    end do
    !$omp end parallel sections

    print 100, var
    100 format ('var =', 3i8)
end program
