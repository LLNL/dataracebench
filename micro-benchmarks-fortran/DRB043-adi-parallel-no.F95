!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!*****************************************************************************
!
!  adi.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
!
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!*****************************************************************************

!!No data race pairs.

! Include polybench common header.
#include "polybench/fpolybench.h"

! Include benchmark-specific header.
! Default data type is double, default size is 10x1024x1024.
#include "polybench/adi.h"

      program adi
      use omp_lib
      implicit none

      POLYBENCH_2D_ARRAY_DECL(x,DATA_TYPE,500, 500)
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,500, 500)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,500, 500)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(x, 500, 500)
      POLYBENCH_ALLOC_2D_ARRAY(a, 500, 500)
      POLYBENCH_ALLOC_2D_ARRAY(b, 500, 500)

!     Initialization
      call init_array(500, x, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_adi(10, 500, x, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument.
      polybench_prevent_dce(print_array(500, x));

!     Deallocation of Arrays
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n
        integer :: i, j, c1, c2

        if (n >= 1) then
            !$omp parallel do private(c2)
            do c1 = 1, n-1
              do c2 = 1, n-1
                x(c1,c2) = (DBLE(c1) * DBLE(c2+1) + 1.0D0) / DBLE(n)
                a(c1,c2) = (DBLE(c1) * DBLE(c2+2) + 2.0D0) / DBLE(n)
                b(c1,c2) = (DBLE(c1) * DBLE(c2+3) + 3.0D0) / DBLE(n)
              end do
            end do
            !$omp end parallel do
        end if
        end subroutine

!       DCE code. Must scan the entire live-out data.
!       Can be used also to check the correctness of the output.

        subroutine print_array(n, x)
        implicit none

        DATA_TYPE, dimension(n, n) :: x
        integer :: n
        integer :: i, j

        do i = 1, n
          do j = 1, n
            write(0, DATA_PRINTF_MODIFIER) x(i, j)
            if (mod((i * 500 + j), 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine

!       Main computational kernel. The whole function will be timed,
!       including the call and return.

        subroutine kernel_adi(tsteps, n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n, tsteps
        !integer :: i1, i2, t
        integer :: c0,c2,c8

        do c0 = 1, 10
            !$omp parallel do private (c8)
            do c2 = 1, 500
                do c8 = 2, 500
                    b(c2,c8) = b(c2,c8)-a(c2,c8)*a(c2,c8)/b(c2,c8-1)
                end do

                do c8 = 2, 500
                    x(c2,c8) = x(c2,c8)-x(c2,c8-1)*a(c2,c8)/b(c2,c8-1)
                end do

                do c8 = 1, 498
                    x(c2,500-c8) = (X(c2,500-c8) - X(c2,500-c8-1) * A(c2,500 - c8 - 1)) / B(c2,500 - 1 - c8)
                end do
            end do
            !$omp end parallel do

            !$omp parallel do
            do c2 = 1, 500
                x(c2,499) = x(c2,499)/b(c2,499)
            end do
            !$omp end parallel do

            !$omp parallel do private(c8)
            do c2 = 1, 500
                do c8 = 2, 500
                    b(c8,c2) = b(c8,c2)-a(c8,c2)*a(c8,c2)/b(c8-1,c2)
                end do

                do c8 = 2, 500
                    x(c8,c2) = x(c8,c2)-x(c8-1,c2)*a(c8,c2)/b(c8-1,c2)
                end do

                do c8 = 1, 498
                    X(500 - c8,c2) = (X(500 - c8,c2) - X(500 - c8 - 1,c2) * A(500 - 1 - c8,c2)) / B(500 - c8,c2)
                end do
            end do
            !$omp end parallel do

            !$omp parallel do
            do c2 = 1, 500
                x(500-1,c2) = x(499,c2)/b(499,c2)
            end do
            !$omp end parallel do
        end do

        end subroutine

      end program
