!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!micro-bench equivalent to the restrict keyword in C-99 in F95. No data race pairs.

module DRB068
    use omp_lib
    implicit none
contains
    subroutine foo(n, a, b, c, d)
        integer, value :: n
        integer :: i
        integer, dimension(:), pointer, intent(out) :: a, b, c, d

        allocate (a(n))
        allocate (b(n))
        allocate (c(n))
        allocate (d(n))

        do i = 1, n
            b(i) = i
            c(i) = i
        end do

        !$omp parallel do
        do i = 1, n
            a(i) = b(i)+c(i)
        end do
        !$omp end parallel do

        if (a(500) /= 1000) then
            print*,a(500)
        end if

        nullify(a,b,c,d)
    end subroutine
end module

program DRB068_restrictpointer2_orig_no
    use omp_lib
    use DRB068
    implicit none

    integer :: n = 1000
    integer, dimension(:), pointer :: a=>null(), b=>null(), c=>null(), d=>null()

    allocate (a(n))
    allocate (b(n))
    allocate (c(n))
    allocate (d(n))

    call foo(n,a,b,c,d)

    if(associated(a))nullify(a)
    if(associated(b))nullify(b)
    if(associated(c))nullify(c)
    if(associated(d))nullify(d)

end program
