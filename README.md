# DataRaceBench 1.1.1

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

## Microbenchmark property labels (P-Labels)

P-Label | Meaning (microbenchmarks with data races)  | P-Label | Meaning (microbenchmarks without data races)
------|-----------------------------------|------|------------------------------
  Y1  | Unresolvable dependences          |  N1  | Embarrassingly parallel
  Y2  | Missing data sharing clauses      |  N2  | Use of data sharing clauses
  Y3  | Missing synchronization           |  N3  | Use of synchronization
  Y4  | SIMD data races                   |  N4  | Use of SIMD directives
  Y5  | Accelerator data races            |  N5  | Use of accelerator directives
  Y6  | Undefined behavior                |  N6  | Use of special language features
  Y7  | Numerical kernel data races       |  N7  | Numerical kernels
  Y8  | Others (e.g. special OpenMP rules)|  N8  | Others (e.g. special OpenMP rules)


## Microbenchmarks with known data races (some have a varying length version)

ID        | Microbenchmark                                |P-Label| Description                                                                  | Source     
----------|-----------------------------------------------|-------|------------------------------------------------------------------------------|----------
1&#124;2  | antidep1-(orig&#124;var)-yes.c                |Y1     | Anti-dependence within a single loop                                         | AutoPar    
3&#124;4  | antidep2-(orig&#124;var)-yes.c                |Y1     | Anti-dependence within a two-level loop nest                                 | AutoPar    
5         | indirectaccess1-orig-yes.c                    |Y7     | Indirect access with overlapped index array elements                         | LLNL App   
6         | indirectaccess2-orig-yes.c                    |Y7     | Overlapping index array elements when 36 or more threads are used            | LLNL App   
7         | indirectaccess3-orig-yes.c                    |Y7     | Overlapping index array elements when 60 or more threads are used            | LLNL App   
8         | indirectaccess4-orig-yes.c                    |Y7     | Overlapping index array elements when 180 or more threads are used           | LLNL App   
9&#124;10 | lastprivatemissing-(orig&#124;var)-yes.c      |Y2     | Data race due to a missing `lastprivate()` clause                            | AutoPar    
11&#124;12| minusminus-(orig&#124;var)-yes.c              |Y3     | Unprotected decrement operation `--`                                         | AutoPar    
13        | nowait-orig-yes.c                             |Y3     | Missing barrier due to a wrongfully used nowait                              | AutoPar    
14&#124;15| outofbounds-(orig&#124;var)-yes.c             |Y6     | Out of bound access of the 2nd dimension of array                            | AutoPar    
16&#124;17| outputdep-(orig&#124;var)-yes.c               |Y1     | Output dependence and true dependence within a loop                          | AutoPar    
18&#124;19| plusplus-(orig&#124;var)-yes.c                |Y1     | increment operation `++` on array index variable                             | AutoPar    
20&#124;21| privatemissing-(orig&#124;var)-yes.c          |Y2     | Missing `private()` for a temp variable                                      | AutoPar    
22&#124;23| reductionmissing-(orig&#124;var)-yes.c        |Y2     | Missing `reduction()` for a variable                                         | AutoPar    
24        | sections1-orig-yes.c                          |Y3     | Unprotected data writes in parallel sections                                 | New        
25&#124;26| simdtruedep-(orig&#124;var)-yes.c             |Y1,Y4  | SIMD instruction level data races                                            | New        
27        | targetparallelfor-orig-yes.c                  |Y1,Y5  | Data races in loops offloaded to accelerators                                | New        
28        | taskdependmissing-orig-yes.c                  |Y3     | Unprotected data writes in two tasks                                         | New        
29&#124;30| truedep1-(orig&#124;var)-yes.c                |Y1     | True data dependence among multiple array elements within a single level loop| AutoPar    
31&#124;32| truedepfirstdimension-(orig&#124;var)-yes.c   |Y1     | True data dependence of first dimension for a 2-D array accesses             | AutoPar    
33&#124;34| truedeplinear-(orig&#124;var)-yes.c           |Y1     | Linear equation as array subscript                                           | AutoPar    
35&#124;36| truedepscalar-(orig&#124;var)-yes.c           |Y1     | True data dependence due to scalar                                           | AutoPar    
37&#124;38| truedepseconddimension-(orig&#124;var)-yes.c  |Y1     | True data dependence on 2nd dimension of a 2-D array accesses                | AutoPar    
39&#124;40| truedepsingleelement-(orig&#124;var)-yes.c    |Y1     | True data dependence due to a single array element                           | AutoPar    
73        | doall2-orig-yes.c                             |Y2     | Missing `private()` for inner loop nest's loop index variable                | New        
74        | flush-orig-yes.c                              |Y2     | Reduction using a shared variable, extracted from an official OpenMP example | New        
75        | getthreadnum-orig-yes.c                       |Y1     | Work sharing within one branch of a `if` statement                           | New        
80        | func-arg-orig-yes.c                           |Y6     | Function arguments passed by reference, inheriting shared attribute          | New        
82        | declared-in-func-orig-yes.c                   |Y6     | A variable declared within a function called by a parallel region            | New
84        | threadprivatemissing-orig-yes.c               |Y2     | Missing threadprivate for a global var, not referenced within a construct    | New
86        | static-data-member-orig-yes.cpp               |Y2     | Missing threadprivate for a static member, not referenced within a construct | New
87        | static-data-member2-orig-yes.cpp              |Y2     | Missing threadprivate for a static member, referenced within a construct     | New
88        | dynamic-storage-origin-yes.c                  |Y2     | Data race for a dynamica storage variable, not referenced within a construct | New
89        | dynamic-storage2-origin-yes.c                 |Y2     | Data race for a dynamica storage variable, referenced within a construct     | New
90        | static-local-orig-yes.c                       |Y2     | Data race for a locally declared static variable                             | New
92        | threadprivatemissing2-orig-yes.c              |Y2     | Missing threadprivate for a variable referenced within a construct           | New
95        | doall2-taskloop-orig-yes.c                    |Y2     | Missing protection for inner loop's loop variable                            | New

## Microbenchmarks without known data races

ID| Microbenchmark                    |P-Label| Description                                                                          | Source     
--|-----------------------------------|-------|--------------------------------------------------------------------------------------|------------
41| 3mm-parallel-no.c                 |N2     | 3-step matrix-matrix multiplication, non-optimized version                           | Polyhedral 
42| 3mm-tile-no.c                     |N2,N4  | 3-step matrix-matrix multiplication, with tiling and nested SIMD                     | Polyhedral 
43| adi-parallel-no.c                 |N2     | Alternating Direction Implicit solver, non-optimized version                         | Polyhedral  
44| adi-tile-no.c                     |N2,N4  | Alternating Direction Implicit solver, with tiling and nested SIMD                   | Polyhedral  
45| doall1-orig-no.c                  |N1     | Classic DOAll loop operating on a one dimensional array                              | AutoPar    
46| doall2-orig-no.c                  |N1     | Classic DOAll loop operating on a two dimensional array                              | AutoPar     
47| doallchar-orig-no.c               |N1     | Classic DOALL loop operating on a character array                                    | New        
48| firstprivate-orig-no.c            |N2     | Example use of firstprivate                                                          | AutoPar    
49| fprintf-orig-no.c                 |N6     | Use of `fprintf()`                                                                   | New        
50| functionparameter-orig-no.c       |N6     | Arrays passed as function parameters                                                 | LLNL App   
51| getthreadnum-orig-no.c            |N2     | single thread execution using `if (omp_get_thread_num()==0)`                         | New              
52| indirectaccesssharebase-orig-no.c |N7     | Indirect array accesses using index arrays without overlapping                       | LLNL App   
53| inneronly1-orig-no.c              |N1     | Two-level nested loops, inner level is parallelizable. True dependence on outer level| AutoPar    
54| inneronly2-orig-no.c              |N1     | Two-level nested loops, inner level is parallelizable. Anti dependence on outer level| AutoPar    
55| jacobi2d-parallel-no.c            |N7     | Jacobi with array copying, no reduction, non-optimized version                       | Polyhedral 
56| jacobi2d-tile-no.c                |N4,N7  | Jacobi with array copying, no reduction, with tiling and nested SIMD                 | Polyhedral 
57| jacobiinitialize-orig-no.c        |N7     | The array initialization parallel loop in Jacobi                                     | AutoPar    
58| jacobikernel-orig-no.c            |N7     | Parallel Jacobi stencil computation kernel with array copying and reduction          | AutoPar    
59| lastprivate-orig-no.c             |N2     | Example use of lastprivate                                                           | AutoPar    
60| matrixmultiply-orig-no.c          |N7     | Classic i-k-j order matrix multiplication using OpenMP                               | AutoPar    
61| matrixvector1-orig-no.c           |N7     | Matrix-vector multiplication parallelized at the outer level loop                    | AutoPar    
62| matrixvector2-orig-no.c           |N7     | Matrix-vector multiplication parallelized at the inner level loop with reduction     | AutoPar    
63| outeronly1-orig-no.c              |N2     | Two-level nested loops, outer level is parallelizable. True dependence on inner level| AutoPar    
64| outeronly2-orig-no.c              |N2     | Two-level nested loops, outer level is parallelizable. Anti dependence on inner level| AutoPar    
65| pireduction-orig-no.c             |N7     | PI calculation using reduction                                                       | AutoPar    
66| pointernoaliasing-orig-no.c       |N6     | Pointers assigned by different malloc calls, without aliasing                        | LLNL App   
67| restrictpointer1-orig-no.c        |N6     | C99 restrict pointers used for array initialization, no aliasing                     | LLNL App    
68| restrictpointer2-orig-no.c        |N6     | C99 restrict pointers used for array computation, no aliasing                        | LLNL App   
69| sectionslock1-orig-no.c           |N3     | OpenMP parallel sections with a lock to protect shared data writes                   | New        
70| simd1-orig-no.c                   |N1,N4  | OpenMP SIMD directive to indicate vectorization of a loop                            | New        
71| targetparallelfor-orig-no.c       |N1,N5  | data races in loops offloaded to accelerators                                        | New        
72| taskdep1-orig-no.c                |N3     | OpenMP task with depend clauses to avoid data races                                  | New         
76| flush-orig-no.c                   |N2     | OpenMP private clause to avoid data races                                            | New         
77| single-orig-no.c                  |N2     | OpenMP single directive to avoid data races                                          | New         
78| taskdep2-orig-no.c                |N3     | OpenMP task depend clause to avoid data races                                        | New         
79| taskdep3-orig-no.c                |N3     | OpenMP task depend clause to avoid data races                                        | New         
81| func-arg-orig-no.c                |N6     | Function arguments passed by value, private                                          | New        
83| declared-in-func-orig-no.c        |N6     | A variable declared within a function called by a parallel region                    | New
85| threadprivate-orig-no.c           |N2     | Use threadprivate to protect a file scope variable, not referenced within a construct| New
91| threadprivate2-orig-no.c          |N2     | Use threadprivate to protect a file scope variable, referenced within a construct    | New
93| doall2-collapse-orig-no.c         |N8     | Use collapse(n) to control the number of associated loops of omp for                 | New
94| doall2-ordered-orig-no.c          |N8     | Use ordered(n) to control the number of associated loops of omp for                  | New
96| doall2-taskloop-collapse-orig-no.c|N8     | Use ordered(n) to control the number of associated loops of taskloop                 | New
## Authors

DataRaceBench was created by Chunhua Liao, Pei-Hung Lin, Joshua Asplund, Markus Schordan, and Ian Karlin.

## Release

DataRaceBench is released under a BSD license. For more details see
the file LICENSE.txt. The microbenchmarks marked 'Polyhedral' in above
table were generated as optimization variants of benchmarks from the
PolyOpt benchmark suite. For those benchmarks see the license file
LICENSE.OSU.txt.

`LLNL-CODE-732144`

## How to cite DataRaceBench in a publication

If you are referring to DataRaceBench in a publication, please cite the following paper:

* Chunhua Liao, Pei-Hung Lin, Joshua Asplund, Markus Schordan, Ian Karlin.
[DataRaceBench: A Benchmark Suite for Systematic Evaluation of Data Race Detection Tools (best paper finalist)](https://dl.acm.org/citation.cfm?doid=3126908.3126958).
Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis, SC 2017, pp. 11:1-11:14, ISBN 978-1-4503-5114-0, Denver, CO, USA, November 12-17, 2017.
