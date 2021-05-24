!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Data race on outLen due to ++ operation.
!Adding private (outLen) can avoid race condition. But it is wrong semantically.
!Data races on outLen also cause output[outLen++] to have data races.
!
!Data race pairs (we allow two pairs to preserve the original code pattern):
!1. outLen@34:9:W vs. outLen@34:9:W
!2. output[]@33:9:W vs. output[]@33:9:W

program DRB018_plusplus_orig_yes
    use omp_lib
    implicit none

    integer :: i, inLen, outLen
    integer :: input(1000)
    integer :: output(1000)

    inLen = 1000
    outLen = 1

    do i = 1, inLen
        input(i) = i
    end do

    !$omp parallel do
    do i = 1, inLen
        output(outLen) = input(i)
        outLen = outLen + 1
    end do
    !$omp end parallel do

    print 100, output(500)
    100 format ("output(500)=",i3)
end program
