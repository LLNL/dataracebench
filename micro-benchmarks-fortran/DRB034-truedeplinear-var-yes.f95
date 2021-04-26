!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A linear expression is used as array subscription.
!Data race pair: a[2*i+1]@53:9:W vs. a[i]@53:18:R

program DRB034_truedeplinear_var_yes
    use omp_lib
    implicit none

    integer :: i, len, uLen, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension(:), allocatable :: a

    len = 2000

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

    do i = 1, len
        a(i) = i
    end do

    uLen = len/2

    !$omp parallel do
    do i = 1, uLen
        a(2*i) = a(i) + 1
    end do
    !$omp end parallel do

    deallocate(args,a)
end program
