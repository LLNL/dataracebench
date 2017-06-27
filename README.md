# DataRaceBench 1.0.0

DataRaceBench is a benchmark suite designed to systematically and
quantitatively evaluate the effectiveness of data race detection
tools. It includes a set of microbenchmarks with and without data
races. Parallelism is represented by OpenMP directives. OpenMP is a
popular parallel programming model for multi-threaded applications.

Note that if you are using gcc for compiling the microbenchmarks, at
least version 4.9 is required to have support for all used OpenMP
directives.

DataRaceBench also comes with an evaluation script
(check-data-races.sh). The script can be used to evaluate the tools
Helgrind, Archer, Thread Sanitizer, and Intel Inspector. In addition a
parameterized test harness (scripts/test-harness.sh) is available
which allows to provide a number of different parameters for the
evaluation. The test harness is used by the evaluation script with
some pre-defined values.

## Overview of benchmarks

Label | Meaning
------|---------------------------------
  Y1  | Unresolvable dependences
  Y2  | Missing data sharing clauses
  Y3  | Missing synchronization
  Y4  | SIMD data races
  Y5  | Accelerator data races
  Y6  | Undefined behaviors
  Y7  | Numerical kernel data races
  N1  | Embarrassingly parallel
  N2  | Use of data sharing clauses
  N3  | Use of synchronization
  N4  | Use of SIMD directives
  N5  | Use of accelerator directives
  N6  | Use of special language features
  N7  | Numerical kernels


## Microbenchmarks with known data races (some have a varying length version)

ID        |P-Label| Microbenchmark                                | Source     | Description
----------|-------|-----------------------------------------------|------------|--------------------------------------------------------------------------
1&#124;2  |Y1     | antidep1-(orig&#124;var)-yes.c                | AutoPar    | Anti-dependence within a single loop
3&#124;4  |Y1     | antidep2-(orig&#124;var)-yes.c                | AutoPar    | Anti-dependence within a two-level loop nest
5         |Y7     | indirectaccess1-orig-yes.c                    | LLNL App   | Indirect access with overlapped index array elements
6         |Y7     | indirectaccess2-orig-yes.c                    | LLNL App   | Overlapping index array elements when 36 or more threads are used
7         |Y7     | indirectaccess3-orig-yes.c                    | LLNL App   | Overlapping index array elements when 60 or more threads are used
8         |Y7     | indirectaccess4-orig-yes.c                    | LLNL App   | Overlapping index array elements when 180 or more threads are used
9&#124;10 |Y2     | lastprivatemissing-(orig&#124;var)-yes.c      | AutoPar    | Data race due to a missing `lastprivate()` clause
11&#124;12|Y3     | minusminus-(orig&#124;var)-yes.c              | AutoPar    | Unprotected `--` operation
13        |Y3     | nowait-orig-yes.c                             | AutoPar    | Missing barrier due to a wrongfully used nowait
14&#124;15|Y6     | outofbounds-(orig&#124;var)-yes.c             | AutoPar    | Out of bound access of the 2nd dimension of array
16&#124;17|Y1     | outputdep-(orig&#124;var)-yes.c               | AutoPar    | Output dependence and true dependence within a loop
18&#124;19|Y1     | plusplus-(orig&#124;var)-yes.c                | AutoPar    | `++` operation on array index variable
20&#124;21|Y2     | privatemissing-(orig&#124;var)-yes.c          | AutoPar    | Missing `private()` for a temp variable
22&#124;23|Y2     | reductionmissing-(orig&#124;var)-yes.c        | AutoPar    | Missing `reduction()` for a variable
24        |Y3     | sections1-orig-yes.c                          | New        | Unprotected data writes in parallel sections
25&#124;26|Y1,Y4  | simdtruedep-(orig&#124;var)-yes.c             | New        | SIMD instruction level data races
27        |Y1,Y5  | targetparallelfor-orig-yes.c                  | New        | Data races in loops offloaded to accelerators
28        |Y3     | taskdependmissing-orig-yes.c                  | New        | Unprotected data writes in two tasks
29&#124;30|Y1     | truedep1-(orig&#124;var)-yes.c                | AutoPar    | True data dependence among multiple array elements within a single level loop
31&#124;32|Y1     | truedepfirstdimension-(orig&#124;var)-yes.c   | AutoPar    | True data dependence of first dimension for a 2-D array accesses
33&#124;34|Y1     | truedeplinear-(orig&#124;var)-yes.c           | AutoPar    | Linear equation as array subscript
35&#124;36|Y1     | truedepscalar-(orig&#124;var)-yes.c           | AutoPar    | True data dependence due to scalar
37&#124;38|Y1     | truedepseconddimension-(orig&#124;var)-yes.c  | AutoPar    | True data dependence on 2nd dimension of a 2-D array accesses
39&#124;40|Y1     | truedepsingleelement-(orig&#124;var)-yes.c    | AutoPar    | True data dependence due to a single array element


## Microbenchmarks without known data races

ID|P-Label| Micro-benchmark                   | Source     | Description
--|-------|-----------------------------------|------------|--------------------------------------------------------------------------------------
41|N2     | 3mm-parallel-no.c                 | Polyhedral | 3-step matrix-matrix multiplication, non-optimized version
42|N2,N4  | 3mm-tile-no.c                     | Polyhedral | 3-step matrix-matrix multiplication, with tiling and nested SIMD
43|N2     | adi-parallel-no.c                 | Polyhedral | Alternating Direction Implicit solver, non-optimized version
44|N2,N4  | adi-tile-no.c                     | Polyhedral | Alternating Direction Implicit solver, with tiling and nested SIMD
45|N1     | doall1-orig-no.c                  | AutoPar    | Classic DOAll loop operating on a one dimensional array
46|N1     | doall2-orig-no.c                  | AutoPar    | Classic DOAll loop operating on a two dimensional array
47|N1     | doallchar-orig-no.c               | New        | Classic DOALL loop operating on a character array
48|N2     | firstprivate-orig-no.c            | AutoPar    | Example use of firstprivate
49|N6     | functionparameter-orig-no.c       | LLNL App   | Arrays passed as function parameters
50|N6     | fprintf-orig-no.c                 | New        | Use of `fprintf()`
51|N2     | getthreadnum-orig-no.c            | New        | single thread execution using `if (omp_get_thread_num()==0)`
52|N7     | indirectaccesssharebase-orig-no.c | LLNL App   | Indirect array accesses using index arrays without overlapping
53|N1     | inneronly1-orig-no.c              | AutoPar    | Two-level nested loops, inner level is parallelizable. True dependence on outer level
54|N1     | inneronly2-orig-no.c              | AutoPar    | Two-level nested loops, inner level is parallelizable. Anti dependence on outer level
55|N7     | jacobi2d-parallel-no.c            | Polyhedral | Jacobi with array copying, no reduction, non-optimized version
56|N4,N7  | jacobi2d-tile-no.c                | Polyhedral | Jacobi with array copying, no reduction, with tiling and nested SIMD
57|N7     | jacobiinitialize-orig-no.c        | AutoPar    | The array initialization parallel loop in Jacobi
58|N7     | jacobikernel-orig-no.c            | AutoPar    | Parallel Jacobi stencil computation kernel with array copying and reduction
59|N2     | lastprivate-orig-no.c             | AutoPar    | Example use of lastprivate
60|N7     | matrixmultiply-orig-no.c          | AutoPar    | Classic i-k-j order matrix multiplication using OpenMP
61|N7     | matrixvector1-orig-no.c           | AutoPar    | Matrix-vector multiplication parallelized at the outer level loop
62|N7     | matrixvector2-orig-no.c           | AutoPar    | Matrix-vector multiplication parallelized at the inner level loop with reduction
63|N2     | outeronly1-orig-no.c              | AutoPar    | Two-level nested loops, outer level is parallelizable. True dependence on inner level
64|N2     | outeronly2-orig-no.c              | AutoPar    | Two-level nested loops, outer level is parallelizable. Anti dependence on inner level
65|N7     | pireduction-orig-no.c             | AutoPar    | PI calculation using reduction
66|N6     | pointernoaliasing-orig-no.c       | LLNL App   | Pointers assigned by different malloc calls, without aliasing
67|N6     | restrictpointer1-orig-no.c        | LLNL App   | C99 restrict pointers used for array initialization, no aliasing
68|N6     | restrictpointer2-orig-no.c        | LLNL App   | C99 restrict pointers used for array computation, no aliasing
69|N3     | sectionslock1-orig-no.c           | New        | OpenMP parallel sections with a lock to protect shared data writes
70|N1,N4  | simd1-orig-no.c                   | New        | OpenMP SIMD directive to indicate vectorization of a loop
71|N1,N5  | targetparallelfor-orig-no.c       | New        | data races in loops offloaded to accelerators
72|N3     | taskdep1-orig-no.c                | New        | OpenMP task with depend clauses to avoid data races

## Authors

DataRaceBench was created by Chunhua Liao, Pei-Hung Lin, Joshua Asplund, Markus Schordan, and Ian Karlin.

## Release

DataRaceBench is released under a BSD license. For more details see
the file LICENSE.txt. The microbenchmarks marked 'Polyhedral' in above
table were generated as optimization variants of benchmarks from the
PolyOpt benchmark suite. For those benchmarks see the license file
LICENSE.OSU.txt.

`LLNL-CODE-732144`
