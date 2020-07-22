!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Use of private() clause. No data race pairs.


module DRB057
    use omp_lib
    implicit none

    integer :: MSIZE
    integer :: n,m,mits
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:,:), pointer :: u,f,uold
    real(dp) :: dx,dy,tol,relax,alpha

contains
    subroutine initialize()
        integer :: i,j,xx,yy

        MSIZE = 200
        mits = 1000
        relax = 1.0
        alpha = 0.0543
        n = MSIZE
        m = MSIZE
        allocate(u(MSIZE,MSIZE))
        allocate(f(MSIZE,MSIZE))
        allocate(uold(MSIZE,MSIZE))

        dx = 2.0D0 / DBLE(n-1)
        dy = 2.0D0 / DBLE(m-1)

        !Initialize initial condition and RHS
        !$omp parallel do private(i,j,xx,yy)
        do i = 1, n
            do j = 1, m
                xx = int(-1.0 + dx * (i-1))
                yy = int(-1.0 + dy * (i-1))
                u(i,j) = 0.0
                f(i,j) = -1.0 * alpha * (1.0-xx*xx) * (1.0-yy*yy) - 2.0* (1.0-xx*xx) -2.0 * (1.0-yy*yy)
            end do
        end do
        !$omp end parallel do

    end subroutine
end module

program DRB057_jacobiinitialize_orig_no
    use omp_lib
    use DRB057
    implicit none

    call initialize()
end program

