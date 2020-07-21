!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A single directive is used to protect a write. No data race pairs.

program DRB077_single_orig_no
    use omp_lib
    implicit none

    integer :: count
    count = 0

    !$omp parallel shared(count)
        !$omp single
        count = count + 1
        !$omp end single
    !$omp end parallel

    print 100, count
    100 format ('count =',i3)
end program
