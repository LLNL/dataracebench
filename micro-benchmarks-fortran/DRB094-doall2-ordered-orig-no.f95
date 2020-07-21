!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!ordered(2) is used to associate two loops with omp for.
!The corresponding loop iteration variables are private.
!
!ordered(n) is an OpenMP 4.5 addition. No data race pairs.


module DRB094
    implicit none
    integer, dimension(:,:), allocatable :: a
end module

program DRB094_doall2_ordered_orig_no
    use omp_lib
    use DRB094
    implicit none

    integer :: len, i, j
    len = 100

    allocate (a(len,len))

    !$omp parallel do ordered(2)
    do i = 1, len
        do j = 1, len
            a(i,j) = a(i,j)+1
            !$omp ordered depend(sink:i-1,j) depend (sink:i,j-1)
            print*,'test i =',i,'  j =',j
            !$omp ordered depend(source)
        end do
    end do
    !$omp end parallel do


end program
