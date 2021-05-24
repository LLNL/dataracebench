!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The outer loop has a loop-carried true dependence.
!Data race pair: b[i][j]@56:13:W vs. b[i-1][j-1]@56:22:R

program DRB032_truedepfirstdimension_var_yes
    use omp_lib
    implicit none

    integer :: i, j, n, m, len, argCount, allocStatus, rdErr, ix
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
    allocate (b(n,m))

    do i = 1, n
        do j = 1, m
            b(i,j) = 0.5
        end do
    end do

    !$omp parallel do private(j)
    do i = 2, n
        do j = 2, m
            b(i,j) = b(i-1, j-1)
        end do
    end do
    !$omp end parallel do

    print 100, b(500,500)
    100 format ('b(500,500) =',F10.6)


    deallocate(args,b)
end program
