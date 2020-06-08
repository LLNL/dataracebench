!This program is extracted from a real application at LLNL.
!Two pointers (xa1 and xa2) have a pair of values with a distance of 12.
!They are used as start base addresses for two 1-D arrays.
!Their index set has two indices with distance of 12: 999 +12 = 1011.
!So there is loop carried dependence.
!
!However, having loop carried dependence does not mean data races will always happen.
!The iterations with loop carried dependence must be scheduled to
!different threads in order for data races to happen.
!
!In this example, we use schedule(static,1) to increase the chance that
!the dependent loop iterations will be scheduled to different threads.
!Data race pair: xa1[idx]@69:5 vs. xa2[idx]@71:5


module DRB005
    implicit none

    integer, dimension(180) :: indexSet
    integer :: n

end module


program DRB005_indirectaccess1_orig_yes
    use omp_lib
    use DRB005
    implicit none

    integer :: i, idx
    real, pointer :: base, xa1, xa2
    allocate(base)
    allocate(xa1)
    allocate(xa2)

    xa1 = base
    xa2 = base+12
    n=180

    indexSet = (/ 521, 523, 525, 527, 529, 531, 547, 549, &
    551, 553, 555, 557, 573, 575, 577, 579, 581, 583, 599, &
    601, 603, 605, 607, 609, 625, 627, 629, 631, 633, 635, &
    651, 653, 655, 657, 659, 661, 859, 861, 863, 865, 867, &
    869, 885, 887, 889, 891, 893, 895, 911, 913, 915, 917, &
    919, 921, 937, 939, 941, 943, 945, 947, 963, 965, 967, &
    969, 971, 973, 989, 991, 993, 995, 997, 999, 1197, 1199, &
    1201, 1203, 1205, 1207, 1223, 1225, 1227, 1229, 1231, &
    1233, 1249, 1251, 1253, 1255, 1257, 1259, 1275, 1277, &
    1279, 1281, 1283, 1285, 1301, 1303, 1305, 1307, 1309, &
    1311, 1327, 1329, 1331, 1333, 1335, 1337, 1535, 1537, &
    1539, 1541, 1543, 1545, 1561, 1563, 1565, 1567, 1569, &
    1571, 1587, 1589, 1591, 1593, 1595, 1597, 1613, 1615, &
    1617, 1619, 1621, 1623, 1639, 1641, 1643, 1645, 1647, &
    1649, 1665, 1667, 1669, 1671, 1673, 1675, 1873, 1875, &
    1877, 1879, 1881, 1883, 1899, 1901, 1903, 1905, 1907, &
    1909, 1925, 1927, 1929, 1931, 1933, 1935, 1951, 1953, &
    1955, 1957, 1959, 1961, 1977, 1979, 1981, 1983, 1985, &
    1987, 2003, 2005, 2007, 2009, 2011, 2013 /)

    do i = 521, 2025
        base = base+i
        base = 0.5*i
    end do

    !$omp parallel do schedule(static,1)
    do i = 1, n
        idx = indexSet(i)
        xa1 = xa1+idx
        xa1 = xa1+1.0+i
        xa2 = xa2+idx
        xa2 = xa2+3.0+i
    end do
    !$omp end parallel do

    print*,'xa1(999) =',xa1+999,' xa2(1285) =',xa2+1285

end program
