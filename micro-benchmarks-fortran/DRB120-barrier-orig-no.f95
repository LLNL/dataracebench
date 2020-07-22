!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The barrier construct specifies an explicit barrier at the point at which the construct appears.
!Barrier construct at line:27 ensures that there is no data race.

program DRB120_barrier_orig_no
    use omp_lib
    implicit none

    integer :: var

    !$omp parallel shared(var)
    !$omp single
    var = var + 1;
    !$omp end single
    !$omp barrier

    !$omp single
    var = var + 1;
    !$omp end single
    !$omp end parallel

    print 100, var
    100 format ('var =',i3)
end program
