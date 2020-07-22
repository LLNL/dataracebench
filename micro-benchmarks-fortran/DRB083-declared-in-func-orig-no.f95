!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A variable is declared inside a function called within a parallel region.
!The variable should be private if it does not use static storage. No data race pairs.

module DRB083
    use omp_lib
    implicit none
    contains
    subroutine foo()
      integer :: q
      q = 0
      q = q+1
    end subroutine foo
end module DRB083

program DRB083_declared_in_func_orig_no
    use omp_lib
    use DRB083
    implicit none

    !$omp parallel
    call foo()
    !$omp end parallel
end program
