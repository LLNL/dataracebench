!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Classic PI calculation using reduction. No data race pairs.

program DRB065_pireduction_orig_no
    use omp_lib
    implicit none

    real(kind = 16) :: x, interval_width, pi
    integer(kind = 8) :: i, num_steps

    pi = 0.0
    num_steps = 2000000000
    interval_width = 1.0/num_steps

    !$omp parallel do reduction(+:pi) private(x)
    do i = 1, num_steps
        x = (i + 0.5) * interval_width
        pi = pi + 1.0 / (x*x + 1.0);
    end do
    !$omp end parallel do

    pi = pi * 4.0 * interval_width;
    print 100, pi
    100 format ("PI =",F24.20)

end program
