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
!       Array initialization.
        subroutine init_array(n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n
        integer :: c1, c2, c3, c4

        if (n >= 1) then
            !$omp parallel do private(c2,c3,c4)
            do c1 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                do c2 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                    do c3 = 16*c1, merge(16*c1+15,n-1,(16*c1+15)<(n-1))
                        !$omp simd
                        do c4 = 16*c2, merge(16*c2+15,n-1,(16*c2+15)<(n-1))
                            x(c3,c4)=(DBLE(c3)*DBLE(c4+1)+1.0D0)/DBLE(n)
                            a(c3,c4)=(DBLE(c3)*DBLE(c4+2)+2.0D0)/DBLE(n)
                            b(c3,c4)=(DBLE(c3)*DBLE(c4+3)+3.0D0)/DBLE(n)
                        end do
                    end do
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

!        Main computational kernel. The whole function will be timed,
!        including the call and return.
        subroutine kernel_adi(tsteps, n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n, tsteps
        !integer :: i1, i2, t
        integer :: c0,c2,c8, c9, c15

        if (n >= 1 .and. tsteps >= 1) then
            do c0 = 1, tsteps
                if (n>=2) then
                    !$omp parallel do private(c15,c9,c8)
                    do c2 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                        do c8 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                            do c9 = merge(2,16*c8,1>16*c8), merge(16*c8+15,n-1,(16*c8+15)<(n-1))
                                !$omp simd
                                do c15 = 16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                                    B(c15,c9) = B(c15,c9) - A(c15,c9) * A(c15,c9) / B(c15,c9 - 1)
                                end do
                            end do
                        end do

                        do c8 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                            do c9 = merge(2,16*c8,2>16*c8), merge(16*c8+15,n-1,(16*c8+15)<(n-1))
                                !$omp simd
                                do c15 = 16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                                    x(c15,c9) = x(c15,c9) - x(c15,c9) * A(c15,c9) / B(c15,c9 - 1)
                                end do
                            end do
                        end do

                        do c8 = 1, merge(merge(-((-(n-3) + 17) / 16),-((-(n-3) + 15) / 16),16<0),(n-3) / 16,(n-3) * 16 < 0)
                            do c9 = 16*c8, merge(16*c8+15,n-3,16*c8+15<n-3)
                                !$omp simd
                                do c15=16*c2, merge(16*c2+15,n-1,16*c2+15 < n-1)
                                    X(c15,n - c9 - 2) = (X(c15,n - 2 - c9) - X(c15,n - 2 - c9 - 1) * A(c15,n - c9 - 3)) / B(c15,n - 3 - c9)
                                end do
                            end do
                        end do
                    end do
                end if

                !$omp parallel do private(c15)
                do c2 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                    !$omp simd
                    do c15=16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                        x(c15,n-1) = x(c15,n-1)/b(c15,n-1)
                    end do
                end do
                !$omp end parallel do

                if (n >= 2) then
                    !$omp parallel do private(c15, c9, c8)
                    do c2 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                        do c8 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                            do c9 = merge(2,16*c8,2>16*c8), merge(16*c8+15,n-1,16*c8+15<n-1)
                                !$omp simd
                                do c15 = 16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                                    B(c9,c15) = B(c9,c15) - A(c9,c15) * A(c9,c15) / B(c9 - 1,c15)
                                end do
                            end do
                        end do

                        do c8 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                            do c9 = merge(2,16*c8,2>16*c8), merge(16*c8+15,n-1,16*c8+15<n-1)
                                !$omp simd
                                do c15 = 16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                                    X(c9,c15) = X(c9,c15) - X(c9 - 1,c15) * A(c9,c15) / B(c9 - 1,c15)
                                end do
                            end do
                        end do

                        do c8 = 1, merge(merge(-((-(n-3) + 17) / 16),-((-(n-3) + 15) / 16),16<0),(n-3) / 16,(n-3) * 16 < 0)
                            do c9 = 16*c8, merge(16*c8+15,n-3,16*c8+15<n-3)
                                !$omp simd
                                do c15=16*c2, merge(16*c2+15,n-1,16*c2+15 < n-1)
                                    X(n - 2 - c9,c15) = (X(n - 2 - c9,c15) - X(n - c9 - 3,c15) * A(n - 3 - c9,c15)) / B(n - 2 - c9,c15)
                                end do
                            end do
                        end do

                    end do
                    !$omp end parallel do
                end if

                !$omp parallel do private(c15)
                do c2 = 1, merge(merge(-((-(n-1) + 17) / 16),-((-(n-1) + 15) / 16),16<0),(n-1) / 16,(n-1) * 16 < 0)
                    !$omp simd
                    do c15 = 16*c2, merge(16*c2+15,n-1,16*c2+15<n-1)
                        X(n - 1,c15) = X(n - 1,c15) / B(n - 1,c15)
                    end do
                end do
                !$omp end parallel do
            end do
        end if


        end subroutine

      end program
