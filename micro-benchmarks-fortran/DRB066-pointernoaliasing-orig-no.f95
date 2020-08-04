!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Freshly allocated pointers do not alias to each other. No data race pairs.

module DRB066
    use omp_lib
    implicit none
contains
    subroutine setup(N)
        integer, value :: N
        integer :: i
        integer, parameter :: dp = kind(1.0d0)
        real(dp),dimension(:), pointer :: m_pdv_sum, m_nvol
        real(dp),dimension(:), allocatable, target :: tar1, tar2

        allocate (m_pdv_sum(N))
        allocate (m_nvol(N))
        allocate (tar1(N))
        allocate (tar2(N))

        m_pdv_sum => tar1
        m_nvol => tar2

        !$omp parallel do schedule(static)
        do i = 1, N
            tar1(i) = 0.0
            tar2(i) = i*2.5
        end do
        !$omp end parallel do

        !print*,tar1(N),tar2(N)
        if (associated(m_pdv_sum)) nullify(m_pdv_sum)
        if (associated(m_nvol)) nullify(m_nvol)
        deallocate(tar1,tar2)
    end subroutine
end module

program DRB066_pointernoaliasing_orig_no
    use omp_lib
    use DRB066
    implicit none

    integer :: N
    N = 1000

    call setup(N)

end program
