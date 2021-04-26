!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

! argument pass-by-reference
! its data-sharing attribute is the same as its actual argument's. i and q are shared.
! Data race pair: q@15:5:W vs. q@15:5:W

subroutine f1(q)
    implicit none
    integer :: q
    q = q+1
end subroutine f1

program DRB080_func_arg_orig_yes
    use omp_lib
    implicit none

    integer :: i

    i = 0

    !$omp parallel
    call f1(i)
    !$omp end parallel

    print*,"i = ",i
end program
