!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

! Iteration 1 and 2 can have conflicting writes to a(1). But if they are scheduled to be run by 
! the same thread, dynamic tools may miss this.
! Data Race Pair, a(0)@39:9:W vs. a(i)@40:22:W

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
    integer, dimension(:), allocatable :: a

    N = 100

    allocate (a(N))

    call load_from_input(a, N)

    
    !$omp parallel do shared(a)
    do i = 1, N
        a(i) = i
        if(i .eq. 2) a(1) = 1
    end do
    !$omp end parallel do

end program
