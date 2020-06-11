!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Using lastprivate() to resolve an output dependence.
!
!Semantics of lastprivate (x):
!causes the corresponding original list item to be updated after the end of the region.
!The compiler/runtime copies the local value back to the shared one within the last iteration.


program DRB059_lastprivate_orig_no
    use omp_lib
    implicit none
    !$omp parallel
    call foo()
    !$omp end parallel
contains
    subroutine foo()
        integer :: i, x
        !$omp parallel do private(i) lastprivate(x)
        do i = 1, 100
            x = i
        end do
        !$omp end parallel do
        print 100, x
        100 format ("x =",i3)
    end subroutine foo
end program
