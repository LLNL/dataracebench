!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!Two loops are associated with omp taskloop due to collapse(2).
!Both loop index variables are private.
!taskloop requires OpenMP 4.5 compilers. No data race pairs.

module DRB096
    implicit none
    integer, dimension(:,:), allocatable :: a
end module

program DRB096_doall2_taskloop_collapse_orig_no
    use omp_lib
    use DRB096
    implicit none

    integer :: len, i, j
    len = 100

    allocate (a(len,len))

    !$omp parallel
        !$omp single
            !$omp taskloop collapse(2)
            do i = 1, len
                do j = 1, len
                    a(i,j) = a(i,j)+1
                end do
            end do
            !$omp end taskloop
        !$omp end single
    !$omp end parallel

    print 100, a(50,50)
    100 format ('a(50,50) =',i3)

end program
