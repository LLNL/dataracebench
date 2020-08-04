!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Array initialization using assignments. No data race pairs.

module DRB067
    use omp_lib
    implicit none
contains
    subroutine foo(newSxx, newSyy, len)
        integer, value :: len
        integer :: i
        integer, parameter :: dp = kind(1.0d0)
        real(dp),dimension(:), pointer :: newSxx, newSyy
        real(dp),dimension(len), target :: tar1, tar2

        allocate (newSxx(len))
        allocate (newSyy(len))

        newSxx => tar1
        newSyy => tar2

        !$omp parallel do private (i) firstprivate (len)
        do i = 1, len
            tar1(i) = 0.0
            tar2(i) = 0.0
        end do
        !$omp end parallel do

        print*,tar1(len),tar2(len)
        
        if(associated(newSxx))nullify(newSxx)
        if(associated(newSyy))nullify(newSyy)

    end subroutine
end module
program DRB067_restrictpointer1_orig_no
    use omp_lib
    use DRB067
    implicit none

    integer :: len = 1000
    integer, parameter :: dp = kind(1.0d0)
    real(dp),dimension(:), pointer :: newSxx, newSyy

    allocate (newSxx(len))
    allocate (newSyy(len))

    call foo(newSxx, newSyy, len)

    if(associated(newSxx))nullify(newSxx)
    if(associated(newSyy))nullify(newSyy)
end program
