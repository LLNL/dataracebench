!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This one has race condition due to true dependence.
!But data races happen at instruction level, not thread level.
!Data race pair: a[i+1]@55:18:R vs. a[i]@55:9:W

program DRB025_simdtruedep_var_yes
    use omp_lib
    implicit none

    integer :: i, len, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension(:), allocatable :: a
    integer, dimension(:), allocatable :: b

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

    allocate (a(len))
    allocate (b(len))

    do i = 1, len
        a(i) = i
        b(i) = i+1
    end do

    !$omp simd
    do i = 1, len-1
        a(i+1) = a(i) + b(i)
    end do

    do i = 1, len
        write(6,*) 'Values for i and a(i) are:', i, a(i)
    end do

    deallocate(args,a,b)

end program
