!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!For the case of a variable which is referenced within a construct:
!objects with dynamic storage duration should be shared.
!Putting it within a threadprivate directive may cause seg fault
!since threadprivate copies are not allocated.
!
!Dependence pair: *counter@25:5:W vs. *counter@25:5:W

program DRB088_dynamic_storage_orig_yes
    use omp_lib
    implicit none
    integer, pointer :: counter

    allocate(counter)

    counter = 0

    !$omp parallel
    counter = counter+1
    !$omp end parallel

    print*,counter

    deallocate(counter)

end program
