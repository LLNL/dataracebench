!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

! Input dependence race: example from OMPRacer: A Scalable and Precise Static Race
! Detector for OpenMP Programs
! Data Race Pair, a(1)@63:26:W vs. a(i)@62:9:W

subroutine load_from_input(a, N)
  integer :: N, i
  integer, dimension(N) :: a

  do i = 1, N
    a(i) = i
  enddo

end subroutine


program DRB171_input_dependence_var_yes
    use omp_lib
    implicit none

    integer :: i, N, argCount, allocStatus, rdErr, ix
    character(len=80), dimension(:), allocatable :: args
    integer, dimension(:), allocatable :: a

    N = 100

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
        read (args(1), '(i10)', iostat=rdErr) N
        if (rdErr /= 0 ) then
            write (*,'(a)') "Error, invalid integer value."
        end if
    end if

    allocate (a(N))

    call load_from_input(a, N)

    
    !$omp parallel do shared(a)
    do i = 1, N
        a(i) = i
        if(N .gt. 10000) a(1) = 1
    end do
    !$omp end parallel do

end program
