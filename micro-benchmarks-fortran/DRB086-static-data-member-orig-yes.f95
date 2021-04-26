!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!For the case of a variable which is not referenced within a construct:
!static data member should be shared, unless it is within a threadprivate directive.
!
!Dependence pair: counter@27:9:W vs. counter@27:9:W

module DRB086
    implicit none
    public :: A, foo

    integer, save :: counter
    integer, save :: pcounter

    type A
        integer :: counter
        integer :: pcounter
    end type
    !$omp threadprivate(pcounter)
contains
    subroutine foo()
        counter = counter + 1
        pcounter = pcounter + 1
    end subroutine
end module

program DRB086_static_data_member_orig_yes
    use omp_lib
    use DRB086
    implicit none

    type(A) :: c
    c = A(0,0)

    !$omp parallel
    call foo()
    !$omp end parallel

    print *,counter,pcounter
end program
