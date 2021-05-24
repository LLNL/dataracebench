!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!A file-scope variable used within a function called by a parallel region.
!No threadprivate is used to avoid data races.
!This is the case for a variable referenced within a construct.
!
!Data race pairs  sum0@34:13:W vs. sum0@34:20:R
!                 sum0@34:13:W vs. sum0@34:13:W


module DRB092
    implicit none
    integer :: sum0, sum1
end module

program DRB092_threadprivatemissing2_orig_yes
    use omp_lib
    use DRB092
    implicit none

    integer :: i, sum
    sum = 0
    sum0 = 0
    sum1 = 0

    !$omp parallel
        !$omp do
        do i = 1, 1001
            sum0 = sum0+i
        end do
        !$omp end do
        !$omp critical
        sum = sum+sum0
        !$omp end critical
    !$omp end parallel

    do i = 1, 1001
        sum1=sum1+i
    end do

    print*,'sum =',sum,'sum1 =',sum1

end program
