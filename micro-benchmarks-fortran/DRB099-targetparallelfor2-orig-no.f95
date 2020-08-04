!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!use of omp target + map + array sections derived from pointers. No data race pairs.


module DRB099
    implicit none
    contains
REAL FUNCTION foo(a,b,N)
    use omp_lib
    implicit none
  INTEGER :: N, i
  integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: a,b

    !$omp target map(to:a(1:N)) map(from:b(1:N))
    !$omp parallel do
    do i = 1, N
        b(i) = a(i)*real(i,dp)
    end do
    !$omp end parallel do
    !$omp end target

  RETURN
END FUNCTION foo
end module

program DRB099_targetparallelfor2_orig_no
    use omp_lib
    use DRB099
    implicit none

    integer :: i, len
  integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: a,b
    real :: x

    len = 1000

    allocate(a(len))
    allocate(b(len))

    do i = 1, len
        a(i) = (real(i,dp))/2.0
        b(i) = 0.0
    end do

    x=foo(a,b,len)
    print*,'b(50) =',b(50)
  
    deallocate(a,b)
end program
