!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!use of omp target + teams + distribute + parallel for. No data race pairs.

program DRB097_target_teams_distribute_orig_no
    use omp_lib
    use ISO_C_Binding
    implicit none
    integer, parameter :: dp = kind(1.0d0)
    integer, parameter :: double_kind = c_double
    integer (kind=8) :: i, i2, len, l_limit, tmp
    real(dp) :: sum, sum2
    real(dp), dimension(:), allocatable :: a, b

    len = 2560
    sum = real(0.0,dp)
    sum2 = real(0.0,dp)

    allocate (a(len))
    allocate (b(len))

    do i = 1, len
        a(i) = real(i,dp)/real(2.0,dp)
        b(i) = real(i,dp)/real(3.0,dp)
    end do

    !$omp target map(to: a(0:len), b(0:len)) map(tofrom: sum)
    !$omp teams num_teams(10) thread_limit(256) reduction (+:sum)
    !$omp distribute
        do i2 = 1, len, 256
            !$omp parallel do reduction (+:sum)
            do i = i2+1, merge(i2+256,len,i2+256<len)
                sum = sum+a(i)*b(i)
            end do
            !$omp end parallel do
        end do
    !$omp end distribute
    !$omp end teams
    !$omp end target

    !$omp parallel do reduction (+:sum2)
    do i = 1, len
        sum2 = sum2+a(i)*b(i)
    end do
    !$omp end parallel do

    print*,'sum =',int(sum),'; sum2 =',int(sum2)

    deallocate(a,b)
end program
