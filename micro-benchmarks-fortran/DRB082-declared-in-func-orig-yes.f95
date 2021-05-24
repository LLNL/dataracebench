!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A variable is declared inside a function called within a parallel region.
!The variable should be shared if it uses static storage.
!
!Data race pair: i@19:7:W vs. i@19:7:W

module global_foo
    use omp_lib
    implicit none
    contains
    subroutine foo()
      integer, save :: i
      i = i+1
      print*,i
    end subroutine foo
end module global_foo

program DRB082_declared_in_func_orig_yes
    use omp_lib
    use global_foo
    implicit none

    !$omp parallel
    call foo()
    !$omp end parallel
end program
