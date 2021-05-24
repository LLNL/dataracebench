!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!When if() evalutes to true, this program has data races due to true dependence within the loop at 31.
!Data race pair: a[i+1]@32:9:W vs. a[i]@32:18:R

program DRB114_if_orig_yes
    use omp_lib
    implicit none

    integer i, len, rem, j
    real :: u
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), allocatable :: a

    len = 100
    allocate (a(len))

    do i = 1, len
        a(i) = i
    end do

    call random_number(u)
    j = FLOOR(100*u)

    !$omp parallel do if (MOD(j,2)==0)
    do i = 1, len-1
        a(i+1) = a(i)+1
    end do
    !$omp end parallel do

    print*,'a(50) =',a(50)

    deallocate(a)
end program
