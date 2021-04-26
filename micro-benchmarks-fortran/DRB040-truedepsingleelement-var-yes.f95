!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Data race pair: a[i]@49:9:W vs. a[0]@49:16:R


program DRB040_truedepsingleelement_var_yes
    use omp_lib
    implicit none

    integer :: len, i, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension(:), allocatable :: a

    len = 1000

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

    allocate (a(len))

    a(1) = 2

    !$omp parallel do
    do i = 1, len
        a(i) = a(i)+a(1)
    end do
    !$omp end parallel do

    print 100, a(0)
    100 format ('a(0) =',i3)

    deallocate(args,a)
end program
