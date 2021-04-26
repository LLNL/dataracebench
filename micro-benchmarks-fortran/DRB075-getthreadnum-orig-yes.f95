!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Test if the semantics of omp_get_thread_num() is correctly recognized.
!Thread with id 0 writes numThreads while other threads read it, causing data races.
!Data race pair: numThreads@22:9:W vs. numThreads@24:31:R


program DRB075_getthreadnum_orig_yes
    use omp_lib
    implicit none

    integer :: numThreads
    numThreads = 0

    !$omp parallel
    if ( omp_get_thread_num()==0 ) then
        numThreads = omp_get_num_threads();
    else
        print*,'numThreads =',numThreads
    end if
    !$omp endparallel
end program
