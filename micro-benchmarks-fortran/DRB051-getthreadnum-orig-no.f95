!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!omp_get_thread_num() is used to ensure serial semantics. No data race pairs.

program DRB051_getthreadnum_orig_no
    use omp_lib
    implicit none

    integer :: numThreads

    !$omp parallel
    if (omp_get_thread_num() == 0) then
        numThreads = omp_get_num_threads()
    end if
    !$omp end parallel

    print 100, numThreads
    100 format ('numThreads =',i3)
end program
