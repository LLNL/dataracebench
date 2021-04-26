!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!This one has data races due to true dependence.
!But data races happen at both instruction and thread level.
!Data race pair: a[i+1]@31:9:W vs. a[i]@31:16:R

program DRB115_forsimd_orig_yes
    use omp_lib
    implicit none

    integer i, len
    integer, dimension(:), allocatable :: a,b

    len = 100
    allocate (a(len))
    allocate (b(len))

    do i = 1, len
        a(i) = i
        b(i) = i+1
    end do

    !$omp simd
    do i = 1, len-1
        a(i+1)=a(i)+b(i)
    end do

    print*,'a(50) =',a(50)

    deallocate(a,b)
end program
