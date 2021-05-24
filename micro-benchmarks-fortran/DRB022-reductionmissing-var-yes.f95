!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A kernel for two level parallelizable loop with reduction:
!if reduction(+:sum) is missing, there is race condition.
!Data race pairs:
!  getSum@60:13:W vs. getSum@60:13:W
!  getSum@60:13:W vs. getSum@60:22:R

program DRB022_reductionmissing_var_yes
    use omp_lib
    implicit none

    integer :: i, j, len, argCount, allocStatus, rdErr, ix
    real :: temp, getSum
    character(len=80), dimension(:), allocatable :: args
    real, dimension (:,:), allocatable :: u

    len = 100
    getSum = 0.0

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

    allocate (u(len, len))

    do i = 1, len
        do j = 1, len
            u(i,j) = 0.5
        end do
    end do

    !$omp parallel do private(temp, i, j)
    do i = 1, len
        do j = 1, len
            temp = u(i,j)
            getSum = getSum + temp * temp
        end do
    end do
    !$omp end parallel do

    print*,"sum =", getSum


    deallocate(args,u)
end program
