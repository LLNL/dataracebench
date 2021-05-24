!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!

!Two pointers have distance of 12 (p1 - p2 = 12).
!They are used as base addresses for indirect array accesses using an index set (another array).
!
!An index set has two indices with distance of 12 :
!indexSet[3]- indexSet[0] = 533 - 521 =  12
!So there is loop carried dependence for N=0 and N=3.
!
!We use the default loop scheduling (static even) in OpenMP.
!It is possible that two dependent iterations will be scheduled
!within a same chunk to a same thread. So there is no runtime data races.
!
!N is 180, two iteraions with N=0 and N= 3 have loop carried dependences.
!For static even scheduling, we must have at least 60 threads (180/60=3 iterations)
!so iteration 0 and 3 will be scheduled to two different threads.
!Data race pair: xa1[idx]@81:9:W vs. xa2[idx]@82:9:W



module DRB007
    implicit none

    integer, dimension(180) :: indexSet
    integer :: n

end module


program DRB007_indirectaccess3_orig_yes
    use omp_lib
    use DRB007
    implicit none

    integer :: i, idx1, idx2
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(:), pointer :: xa1=>NULL(), xa2=>NULL()
    real(dp), dimension(2025), target :: base

    allocate (xa1(2025))
    allocate (xa2(2025))

    xa1 => base(1:2025)
    xa2 => base(1:2025)

    n=180

    indexSet = (/ 521, 523, 525, 533, 529, 531, 547, 549, &
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
        base(i) = 0.5*i
    end do

    !$omp parallel do
    do i = 1, n
        idx1 = indexSet(i)
        idx2 = indexSet(i)+12
        base(idx1) = base(idx1)+1.0
        base(idx2) = base(idx2)+3.0
    end do
    !$omp end parallel do

    print*,'xa1(999) =',base(999),' xa2(1285) =',base(1285)

    nullify(xa1,xa2)
end program
