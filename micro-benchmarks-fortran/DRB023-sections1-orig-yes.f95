!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two tasks without synchronization to protect data write, causing data races.
!Data race pair: i@20:5:W vs. i@22:5:W

program DRB023_sections1_orig_yes
    use omp_lib
    implicit none

    integer :: i
    i = 0

    !$omp parallel sections
    !$omp section
    i=1
    !$omp section
    i=2
    !$omp end parallel sections

    print 100, i
    100 format ("i=",i3)

end program
