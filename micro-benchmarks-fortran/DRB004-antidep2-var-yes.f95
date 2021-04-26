!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two nested loops with loop-carried anti-dependence on the outer level.
!This is a variable-length array version in F95.
!Data race pair: a[i][j]@55:13:W vs. a[i+1][j]@55:31:R

program DRB004_antidep2_var_yes
    use omp_lib
    implicit none

    integer :: i, j, len, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    real, dimension (:,:), allocatable :: a
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

    allocate (a(len,len))


    do i = 1, len
        do j = 1, len
            a(i,j) = 0.5
        end do
    end do

    !$omp parallel do private(j)
    do i = 1, len-1
        do j = 1, len
            a(i,j) = a(i,j) + a(i+1,j)
        end do
    end do
    !$omp end parallel do

    write(*,*) 'a(10,10) =', a(10,10)

    deallocate(a)
    deallocate(args)

end program
