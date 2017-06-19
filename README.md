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

P-Label| Microbenchmark                           | Source     | Description
-------|------------------------------------------|------------|----------------------------------------------------------------------------------------
Y1     | antidep1-(orig&#124;var)-yes.c                | AutoPar    | Anti-dependence within a single loop
Y1     | antidep2-(orig&#124;var)-yes.c                | AutoPar    | Anti-dependence within a two-level loop nest
Y7     | indirectaccess1-orig-yes.c                    | LLNL App   | Indirect access with overlapped index array elements
Y7     | indirectaccess2-orig-yes.c                    | LLNL App   | Overlapping index array elements when 36 or more threads are used
Y7     | indirectaccess3-orig-yes.c                    | LLNL App   | Overlapping index array elements when 60 or more threads are used
Y7     | indirectaccess4-orig-yes.c                    | LLNL App   | Overlapping index array elements when 180 or more threads are used
Y2     | lastprivatemissing-(orig&#124;var)-yes.c      | AutoPar    | Data race due to a missing `lastprivate()` clause
Y3     | minusminus-(orig&#124;var)-yes.c              | AutoPar    | Unprotected `--` operation
Y3     | nowait-orig-yes.c                             | AutoPar    | Missing barrier due to a wrongfully used nowait
Y6     | outofbounds-(orig&#124;var)-yes.c             | AutoPar    | Out of bound access of the 2nd dimension of array
Y1     | outputdep-(orig&#124;var)-yes.c               | AutoPar    | Output dependence and true dependence within a loop
Y1     | plusplus-(orig&#124;var)-yes.c                | AutoPar    | `++` operation on array index variable
Y2     | privatemissing-(orig&#124;var)-yes.c          | AutoPar    | Missing `private()` for a temp variable
Y2     | reductionmissing-(orig&#124;var)-yes.c        | AutoPar    | Missing `reduction()` for a variable
Y3     | sections1-orig-yes.c                          | New        | Unprotected data writes in parallel sections
Y1,Y4  | simdtruedep-(orig&#124;var)-yes.c             | New        | SIMD instruction level data races
Y1,Y5  | targetparallelfor-orig-yes.c                  | New        | Data races in loops offloaded to accelerators
Y3     | taskdependmissing-orig-yes.c                  | New        | Unprotected data writes in two tasks
Y1     | truedep1-(orig&#124;var)-yes.c                | AutoPar    | True data dependence among multiple array elements within a single level loop
Y1     | truedepfirstdimension-(orig&#124;var)-yes.c   | AutoPar    | True data dependence of first dimension for a 2-D array accesses
Y1     | truedeplinear-(orig&#124;var)-yes.c           | AutoPar    | Linear equation as array subscript
Y1     | truedepscalar-(orig&#124;var)-yes.c           | AutoPar    | True data dependence due to scalar
Y1     | truedepseconddimension-(orig&#124;var)-yes.c  | AutoPar    | True data dependence on 2nd dimension of a 2-D array accesses
Y1     | truedepsingleelement-(orig&#124;var)-yes.c    | AutoPar    | True data dependence due to a single array element


## Microbenchmarks without known data races

P-Label| Micro-benchmark                    | Source     | Description
-------|-----------------------------------|------------|--------------------------------------------------------------------------------------
N2     | 3mm-parallel-no.c                 | Polyhedral | 3-step matrix-matrix multiplication, non-optimized version
N2,N4  | 3mm-tile-no.c                     | Polyhedral | 3-step matrix-matrix multiplication, with tiling and nested SIMD
N2     | adi-parallel-no.c                 | Polyhedral | Alternating Direction Implicit solver, non-optimized version
N2,N4  | adi-tile-no.c                     | Polyhedral | Alternating Direction Implicit solver, with tiling and nested SIMD
N1     | doall1-orig-no.c                  | AutoPar    | Classic DOAll loop operating on a one dimensional array
N1     | doall2-orig-no.c                  | AutoPar    | Classic DOAll loop operating on a two dimensional array
N1     | doallchar-orig-no.c               | New        | Classic DOALL loop operating on a character array
N2     | firstprivate-orig-no.c            | AutoPar    | Example use of firstprivate
N6     | functionparameter-orig-no.c       | LLNL App   | Arrays passed as function parameters
N6     | fprintf-orig-no.c                 | New        | Use of `fprintf()`
N2     | getthreadnum-orig-no.c            | New        | single thread execution using `if (omp_get_thread_num()==0)`
N7     | indirectaccesssharebase-orig-no.c | LLNL App   | Indirect array accesses using index arrays without overlapping
N1     | inneronly1-orig-no.c              | AutoPar    | Two-level nested loops, inner level is parallelizable. True dependence on outer level
N1     | inneronly2-orig-no.c              | AutoPar    | Two-level nested loops, inner level is parallelizable. Anti dependence on outer level
N7     | jacobi2d-parallel-no.c            | Polyhedral | Jacobi with array copying, no reduction, non-optimized version
N4,N7  | jacobi2d-tile-no.c                | Polyhedral | Jacobi with array copying, no reduction, with tiling and nested SIMD
N7     | jacobiinitialize-orig-no.c        | AutoPar    | The array initialization parallel loop in Jacobi
N7     | jacobikernel-orig-no.c            | AutoPar    | Parallel Jacobi stencil computation kernel with array copying and reduction
N2     | lastprivate-orig-no.c             | AutoPar    | Example use of lastprivate
N7     | matrixmultiply-orig-no.c          | AutoPar    | Classic i-k-j order matrix multiplication using OpenMP
N7     | matrixvector1-orig-no.c           | AutoPar    | Matrix-vector multiplication parallelized at the outer level loop
N7     | matrixvector2-orig-no.c           | AutoPar    | Matrix-vector multiplication parallelized at the inner level loop with reduction
N2     | outeronly1-orig-no.c              | AutoPar    | Two-level nested loops, outer level is parallelizable. True dependence on inner level
N2     | outeronly2-orig-no.c              | AutoPar    | Two-level nested loops, outer level is parallelizable. Anti dependence on inner level
N7     | pireduction-orig-no.c             | AutoPar    | PI calculation using reduction
N6     | pointernoaliasing-orig-no.c       | LLNL App   | Pointers assigned by different malloc calls, without aliasing
N6     | restrictpointer1-orig-no.c        | LLNL App   | C99 restrict pointers used for array initialization, no aliasing
N6     | restrictpointer2-orig-no.c        | LLNL App   | C99 restrict pointers used for array computation, no aliasing
N3     | sectionslock1-orig-no.c           | New        | OpenMP parallel sections with a lock to protect shared data writes
N1,N4  | simd1-orig-no.c                   | New        | OpenMP SIMD directive to indicate vectorization of a loop
N1,N5  | targetparallelfor-orig-no.c       | New        | data races in loops offloaded to accelerators
N3     | taskdep1-orig-no.c                | New        | OpenMP task with depend clauses to avoid data races

