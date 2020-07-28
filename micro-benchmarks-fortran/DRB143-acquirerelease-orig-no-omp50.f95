!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!The below program will fail to order the write to x on thread 0 before the read from x on thread 1.
!The implicit release flush on exit from the critical region will not synchronize with the acquire
!flush that occurs on the atomic read operation performed by thread 1. This is because implicit
!release flushes that occur on a given construct may only synchronize with implicit acquire flushes
!on a compatible construct (and vice-versa) that internally makes use of the same synchronization
!variable.
!
!Implicit flush must be used after critical construct to avoid data race.
!No Data Race pair

program DRB142_acquirerelease_orig_yes
    use omp_lib
    implicit none

    integer :: x, y, thrd
    integer :: tmp
    x = 0

    !$omp parallel num_threads(2) private(thrd) private(tmp)
        thrd = omp_get_thread_num()
        if (thrd == 0) then
            !$omp critical
            x = 10
            !$omp end critical

            !$omp flush(x)

            !$omp atomic write
            y = 1
            !$omp end atomic
        else
            tmp = 0
            do while(tmp == 0)
            !$omp atomic read acquire ! or seq_cst
            tmp = x
            !$omp end atomic
            end do
            !$omp critical
            print *, "x = ", x
            !$omp end critical
        end if
    !$omp end parallel
end program
