!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A single thread will spawn all the tasks. Add if(0) to avoid the data race, undeferring the tasks.
!Data Race Pairs, var@21:9:W vs. var@21:9:W

program DRB123_taskundeferred_orig_yes
    use omp_lib
    implicit none

    integer :: var, i
    var = 0

    !$omp parallel sections
    do i = 1, 10
        !$omp task shared(var) 
        var = var+1;
        !$omp end task
    end do
    !$omp end parallel sections

    print 100, var
    100 format ('var =', 3i8)
end program
