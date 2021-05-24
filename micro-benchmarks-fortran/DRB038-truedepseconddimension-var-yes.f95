!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Only the outmost loop can be parallelized in this program.
!Data race pair: b[i][j]@51:13:W vs. b[i][j-1]@51:22:R

program DRB038_truedepseconddimension_var_yes
    use omp_lib
    implicit none

    integer i, j, n, m, len, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    real, dimension(:,:), allocatable :: b

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

    n = len
    m = len

    allocate (b(len,len))

    do i = 1, n
        !$omp parallel do
        do j = 2, m
            b(i,j) = b(i,j-1)
        end do
        !$omp end parallel do
    end do
!    print 100, b(5,5)
!    100 format ('b(5,5) =', F20.6)

    deallocate(args,b)
end program
