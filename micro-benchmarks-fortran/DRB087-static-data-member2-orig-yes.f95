!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!For the case of a variable which is referenced within a construct:
!static data member should be shared, unless it is within a threadprivate directive.
!
!Dependence pair: counter@37:5:W vs. counter@37:5:W


module DRB087
    implicit none
    public :: A

    integer, save :: counter
    integer, save :: pcounter

    type A
        integer :: counter = 0
        integer :: pcounter = 0
    end type
    !$omp threadprivate(pcounter)
end module

program DRB087_static_data_member2_orig_yes
    use omp_lib
    use DRB087
    implicit none

    type(A) :: c
    c = A(0,0)

    !$omp parallel
    counter = counter+1
    pcounter = pcounter+1
    !$omp end parallel

    print *,counter,pcounter
end program
