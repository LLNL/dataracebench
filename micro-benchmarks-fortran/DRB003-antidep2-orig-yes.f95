!A two-level loop nest with loop carried anti-dependence on the outer level.
!Data race pair: a[i][j]@22:13 vs. a[i+1][j]@22:31

program DRB003_antidep2_orig_yes
    use omp_lib
    implicit none

    integer :: i, j, len
    real :: a(20,20)

    len = 20

    do i = 1, len
        do j = 1, len
            a(i,j) = 0.5
        end do
    end do

    !$omp parallel do private(j)
    do i = 1, len-1
        do j = 1, len
            a(i,j) = a(i,j) + a(i+1,j)
        end do
    end do
    !$omp end parallel do

    write(*,*) 'a(10,10) =', a(10,10)

end program
