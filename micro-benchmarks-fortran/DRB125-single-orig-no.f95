!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This example is derived from an example by Simone Atzeni, NVIDIA.
!
!Description: Race on variable init if used master construct. The variable is written by the
!master thread and concurrently read by the others.
!
!Solution: master construct does not have an implicit barrier better
!use single at line 26. Fixed version for DRB124-master-orig-yes.c. No data race.


program DRB125_single_orig_no
    use omp_lib
    implicit none

    integer :: init, local

    !$omp parallel shared(init) private(local)
        !$omp single
        init = 10
        !$omp end single
        local = init
    !$omp end parallel
end program
