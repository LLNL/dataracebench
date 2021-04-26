!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The thread encountering the taskwait directive at line 22 only waits for its child task
!(line 14-21) to complete. It does not wait for its descendant tasks (line 16-19). Data Race pairs, sum@36:13:W vs. sum@36:13:W

program DRB117_taskwait_waitonlychild_orig_yes
    use omp_lib
    implicit none

    integer, dimension(:), allocatable :: a, psum
    integer :: sum, i

    allocate(a(4))
    allocate(psum(4))

    !$omp parallel num_threads(2)
        !$omp do schedule(dynamic, 1)
        do i = 1, 4
            a(i) = i
        end do
        !$omp end do

        !$omp single
            !$omp task
                !$omp task
                  psum(2) = a(3)+a(4)
                !$omp end task
               psum(1) = a(1)+a(2)
            !$omp end task
            !$omp taskwait
            sum = psum(2)+psum(1)
        !$omp end single
    !$omp end parallel

    print*,'sum =',sum

    deallocate(a,psum)
end program
