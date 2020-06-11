!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two parallel for loops within one single parallel region,
!combined with private() and reduction().

!3.7969326424804763E-007 vs 3.7969326424804758E-007. There is no race condition. The minute
!difference at 22nd point after decimal is due to the precision in fortran95

module DRB058
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
        tol=0.0000000001
        relax = 1.0
        alpha = 0.0543
        n = MSIZE
        m = MSIZE
        allocate(u(MSIZE,MSIZE))
        allocate(f(MSIZE,MSIZE))
        allocate(uold(MSIZE,MSIZE))

        dx = 2.0D0 / DBLE(n-1)
        dy = 2.0D0 / DBLE(m-1)

        do i = 1, n
            do j = 1, m
                xx = int(-1.0 + dx * (i-1))
                yy = int(-1.0 + dy * (i-1))
                u(i,j) = 0.0
                f(i,j) = -1.0 * alpha * (1.0-xx*xx) * (1.0-yy*yy) - 2.0* (1.0-xx*xx) -2.0 * (1.0-yy*yy)
            end do
        end do

    end subroutine

    subroutine jacobi()
        integer, parameter :: dp = kind(1.0d0)
        real(dp) :: omega
        integer :: i, j, k
        real(dp) :: error, resid,  ax, ay, b

        MSIZE = 200
        mits = 1000
        tol=0.0000000001
        relax = 1.0
        alpha = 0.0543
        n = MSIZE
        m = MSIZE

        omega = relax
        dx = 2.0D0 / DBLE(n-1)
        dy = 2.0D0 / DBLE(m-1)

        ax = 1.0D0 / (dx * dx);         !/* X-direction coef */
        ay = 1.0D0 / (dy * dy);         !/* Y-direction coef */
        b = -2.0D0 / (dx * dx) - 2.0D0 / (dy * dy) - alpha;

        error = 10.0 * tol
        k = 1

        do k = 1, mits
            error = 0.0

            !Copy new solution into old
            !$omp parallel
                !$omp do private(i,j)
                    do i = 1, n
                        do j = 1, m
                            uold(i,j) = u(i,j)
                        end do
                    end do
                !$omp end do
                !$omp do private(i,j,resid) reduction(+:error)
                    do i = 2, (n-1)
                        do j = 2, (m-1)
                            resid = (ax * (uold(i - 1,j) + uold(i + 1,j)) + ay * (uold(i,j - 1) + uold(i,j + 1)) + b * uold(i,j) - f(i,j)) / b
                            u(i,j) = uold(i,j) - omega * resid
                            error = error + resid * resid
                        end do
                    end do
                !$omp end do nowait
            !$omp end parallel

            !Error check
            error = sqrt(error)/(n*m)
        end do

        print*,"Total number of iterations: ",k
        print*,"Residual: ",error

    end subroutine
end module

program DRB058_jacobikernel_orig_no
    use omp_lib
    use DRB058
    implicit none

    call initialize()
    call jacobi()
end program
