!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Example of writing to a file. No data race pairs.

program DRB049_fprintf_orig_no
    use omp_lib
    implicit none

    integer i, ret, len, stat
    integer :: a(1000)
    logical :: exist

    len = 1000

    do i = 1, len
        a(i) = i
    end do

    inquire(file="mytempfile.txt", exist=exist)

    if (exist) then
        open(6, file="mytempfile.txt", iostat=stat, status="old", position="append", action="write")
    else
        open(6, file="mytempfile.txt", iostat=stat, status="new", action="write")
    end if

    !$omp parallel do
    do i = 1, len
        write(6, *) a(i)
    end do
    !$omp end parallel do

    if (stat == 0) close(6, status='delete')

end program
