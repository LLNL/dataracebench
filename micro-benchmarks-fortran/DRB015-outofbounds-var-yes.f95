!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The outmost loop is be parallelized.
!But the inner level loop has out of bound access for b[i][j] when j equals to 0.
!This will case memory access of a previous row's last element.
!
!For example, an array of 4x4:
!    j=0 1 2 3
! i=0  x x x x
!   1  x x x x
!   2  x x x x
!   3  x x x x
!
!  outer loop: i=2,
!  inner loop: j=0
!  array element accessed b[i][j-1] becomes b[2][-1], which in turn is b[1][3]
!  due to linearized row-major storage of the 2-D array.
!
!This causes loop-carried data dependence between i=2 and i=1.
!Data race pair: b[i][j]@67 vs. b[i][j-1]@67


program DRB015_outofbounds_var_yes
    use omp_lib
    implicit none

    integer :: i, j, n, m, len, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    real, dimension (:,:), allocatable :: b
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

    n = len
    m = len

    allocate (b(n,m))

    !$omp parallel do private(j)
    do i = 2, n
        do j = 1, m
            b(i,j) = b(i,j-1)
        end do
    end do
    !$omp end parallel do
    print*,"b(50,50)=",b(50,50)

    deallocate(args,b)
end program
