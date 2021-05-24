!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The -1 operation is not protected, causing race condition.
!Data race pair: numNodes2@59:13:W vs. numNodes2@59:13:W

program DRB012_minusminus_var_yes
    use omp_lib
    implicit none

    integer :: i, len, numNodes, numNodes2, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension (:), allocatable :: x

    len = 100

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
        read (args(1), '(i10)', iostat=rdErr) len
        if (rdErr /= 0 ) then
            write (*,'(a)') "Error, invalid integer value."
        end if
    end if

    allocate (x(len))

    numNodes=len
    numNodes2=0
    !initialize x()
    do i = 1, len
        if (MOD(i,2) == 0) then
            x(i) = 5
        else
            x(i) = -5
        end if
    end do

    !$omp parallel do
    do i = numNodes, 1, -1
        if (x(i) <= 0) then
            numNodes2 = numNodes2-1
        end if
    end do
    !$omp end parallel do

    print*,"numNodes2 =", numNodes2

    deallocate(args,x)
end program
