!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is derived from an example by Simone Atzeni, NVIDIA.
!
!Description: Race on variable init. The variable is written by the
!master thread and concurrently read by the others.
!
!Solution: master construct at line 23:24 does not have an implicit barrier better
!use single. Data Race Pair, init@24:9:W vs. init@26:17:R

program DRB124_master_orig_yes
    use omp_lib
    implicit none

    integer :: init, local

    !$omp parallel shared(init) private(local)
        !$omp master
        init = 10
        !$omp end master
        local = init
    !$omp end parallel

end program
