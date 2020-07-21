!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is based on fpriv_sections.1.c OpenMP Examples 5.0.0
!The section construct modifies the value of section_count which breaks the independence of the
!section constructs. If the same thread executes both the section one will print 1 and the other
!will print 2. For a same thread execution, there is no data race.

program DRB126_firstprivatesections_orig_no
    use omp_lib
    implicit none

    integer :: section_count

    section_count = 0

    call omp_set_dynamic(.FALSE.)
    call omp_set_num_threads(1)

    !$omp parallel
    !$omp sections firstprivate( section_count )
        !$omp section
        section_count = section_count+1
        print 100, section_count
        100 format ('section_count =',3i8)

        !$omp section
        section_count = section_count+1
        print 101, section_count
        101 format ('section_count =',3i8)
    !$omp end sections
    !$omp end parallel
end program
