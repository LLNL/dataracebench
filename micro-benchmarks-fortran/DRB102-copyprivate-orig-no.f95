!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!threadprivate+copyprivate: no data races

module DRB102
    implicit none
    integer y
    integer, parameter :: dp = kind(1.0d0)
    real(dp) :: x
    !$omp threadprivate(x,y)
end module

program DRB102_copyprivate_orig_no
    use omp_lib
    use DRB102
    implicit none

    !$omp parallel
        !$omp single
        x=1.0
        y=1
        !$omp end single copyprivate(x,y)
    !$omp end parallel

    print 100, x, y
    100 format ('x =',F3.1,2x,'y =',i3)

end program
