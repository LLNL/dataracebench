!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Referred from worksharing_critical.1.f
!A single thread executes the one and only section in the sections region, and executes the
!critical region. The same thread encounters the nested parallel region, creates a new team
!of threads, and becomes the master of the new team. One of the threads in the new team enters
!the single region and increments i by 1. At the end of this example i is equal to 2.

program DRB139_worksharingcritical_orig_no
    use omp_lib
    implicit none

    integer :: i
    i = 1

    !$OMP PARALLEL SECTIONS
    !$OMP SECTION
        !$OMP CRITICAL (NAME)
            !$OMP PARALLEL
                !$OMP SINGLE
                i = i + 1
                !$OMP END SINGLE
            !$OMP END PARALLEL
        !$OMP END CRITICAL (NAME)
    !$OMP END PARALLEL SECTIONS

    print 100,i
    100 format ("i = ", 3i8)
end program
