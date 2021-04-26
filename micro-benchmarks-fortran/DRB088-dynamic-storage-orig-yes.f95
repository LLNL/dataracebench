!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!For the case of a variable which is not referenced within a construct:
!objects with dynamic storage duration should be shared.
!Putting it within a threadprivate directive may cause seg fault since
! threadprivate copies are not allocated!
!
!Dependence pair: *counter@22:9:W vs. *counter@22:9:W


module DRB088
    implicit none
    integer, pointer :: counter

    contains
    subroutine foo()
        counter = counter+1
    end subroutine
end module
program DRB088_dynamic_storage_orig_yes
    use omp_lib
    use DRB088
    implicit none

    allocate(counter)

    counter = 0

    !$omp parallel
    call foo()
    !$omp end parallel

    print*,counter

    deallocate(counter)

end program
