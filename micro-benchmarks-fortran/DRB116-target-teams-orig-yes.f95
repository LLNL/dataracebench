!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!use of omp target + teams
!Without protection, master threads from two teams cause data races.
!Data race pair: a@24:9:W vs. a@24:9:W

program DRB116_target_teams_orig_yes
    use omp_lib
    implicit none

    integer i, len
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: a

    len = 100
    allocate (a(len))

    do i = 1, len
        a(i) = (real(i,dp))/2.0
    end do

    !$omp target map(tofrom: a(0:len))
        !$omp teams num_teams(2)
        a(50) = a(50)*2.0
        !$omp end teams
    !$omp end target

    print*,'a(50)=',a(50)

    deallocate(a)
end program
