!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two-dimensional array computation:
!Only one loop is associated with omp taskloop.
!The inner loop's loop iteration variable will be shared if it is shared in the enclosing context.
!Data race pairs (we allow multiple ones to preserve the pattern):
!  Write_set = {j@36:20 (implicit step +1)}
!  Read_set = {j@36:20, j@37:35}
!  Any pair from Write_set vs. Write_set  and Write_set vs. Read_set is a data race pair.

!need to run with large thread number and large num of iterations.

module DRB095
    implicit none
    integer, dimension(:,:), allocatable :: a
end module

program DRB095_doall2_taskloop_orig_yes
    use omp_lib
    use DRB095
    implicit none

    integer :: len, i, j
    len = 100
    allocate (a(len,len))

    !$omp parallel
        !$omp single
            !$omp taskloop
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
