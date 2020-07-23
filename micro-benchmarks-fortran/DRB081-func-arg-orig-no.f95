!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A function argument passed by value should be private inside the function.
!Variable i is read only. No data race pairs.

module global
    implicit none
    contains
    subroutine f1(i)
      integer, value :: i
      i = i+1
    end subroutine f1
end module global

program DRB080_func_arg_orig_yes
    use omp_lib
    use global
    implicit none

    integer :: i
    i = 0

    !$omp parallel
    call f1(i)
    !$omp end parallel

    if (i /= 0) then
        print 100, i
        100 format ('i =',i3)
    end if
end program
