!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Race condition on outLen due to unprotected writes.
!Adding private (outLen) can avoid race condition. But it is wrong semantically.
!
!Data race pairs: we allow two pair to preserve the original code pattern.
!1. outLen@60:9:W vs. outLen@60:9:W
!2. output[]@59:9:W vs. output[]@59:9:W


program DRB019_plusplus_var_yes
    use omp_lib
    implicit none

    integer :: i, inLen, outLen, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension(:), allocatable :: input
    integer, dimension(:), allocatable :: output

    inLen = 1000
    outLen = 1

    argCount = command_argument_count()
    if (argCount == 0) then
        write (*,'(a)') "No command line arguments provided."
    end if

    allocate(args(argCount), stat=allocStatus)
    if (allocStatus > 0) then
        write (*,'(a)') "Allocation error, program terminated."
        stop
    end if

    do ix = 1, argCount
        call get_command_argument(ix,args(ix))
    end do

    if (argCount >= 1) then
        read (args(1), '(i10)', iostat=rdErr) inLen
        if (rdErr /= 0 ) then
            write (*,'(a)') "Error, invalid integer value."
        end if
    end if

    allocate (input(inLen))
    allocate (output(inLen))

    do i = 1, inLen
        input(i) = i
    end do

    !$omp parallel do
    do i = 1, inLen
        output(outLen) = input(i)
        outLen = outLen + 1
    end do
    !$omp end parallel do

    print 100, output(0)
    100 format ("output(0)=",i3)


    deallocate(input,output,args)
end program
