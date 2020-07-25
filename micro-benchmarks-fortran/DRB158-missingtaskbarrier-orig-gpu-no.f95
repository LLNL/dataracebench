!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Depend clause at line 29 and 33 will ensure that there is no data race.

module DRB158
    integer :: a, i
    integer :: x(64), y(64)
end module

program DRB158_missingtaskbarrier_orig_gpu_no
    use omp_lib
    use DRB158
    implicit none

    do i = 1, 64
        x(i) = 0
        y(i) = 3
    end do

    a = 5

    !$omp target map(to:y,a) map(tofrom:x) device(0)
    do i = 1, 64
        !$omp task depend(inout:x(i))
        x(i) = a*x(i)
        !$omp end task

        !$omp task depend(inout:x(i))
        x(i) = x(i)+y(i)
        !$omp end task
    end do
    !$omp end target

    do i = 1, 64
        if (x(i) /= 3) then
            print*,x(i)
        end if
    end do

    !$omp taskwait

end program
