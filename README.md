# DataRaceBench 1.2.0

DataRaceBench is a benchmark suite designed to systematically and
quantitatively evaluate the effectiveness of data race detection
tools. It includes a set of microbenchmarks with and without data
races. Parallelism is represented by OpenMP directives. OpenMP is a
popular parallel programming model for multi-threaded applications.

Note that some microbenchmarks use OpenMP 4.5 features. Those are:
  DRB094-doall2-ordered-orig-no.c
  DRB095-doall2-taskloop-orig-yes.c (requires gcc 7.x)
  DRB096-doall2-taskloop-collapse-orig-no.c (requires gcc 7.x)
  DRB100-task-reference-orig-no.cpp 
  DRB112-linear-orig-no.c
You need a recent OpenMP compiler (e.g. gcc 7.x or later) to compile them. 

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
  Y1  | Unresolvable dependences          |  N1  | Embarrassingly parallel or single thread execution
  Y2  | Missing data sharing clauses      |  N2  | Use of data sharing clauses
  Y3  | Missing synchronization           |  N3  | Use of synchronization
  Y4  | SIMD data races                   |  N4  | Use of SIMD directives
  Y5  | Accelerator data races            |  N5  | Use of accelerator directives
  Y6  | Undefined behavior                |  N6  | Use of special language features
  Y7  | Numerical kernel data races       |  N7  | Numerical kernels

## Microbenchmarks with known data races (some have a varying length version)

Microbenchmark                                      |P-Label| Description                                                                  | Source     
----------------------------------------------------|-------|------------------------------------------------------------------------------|----------
DRD001-antidep1-orig-yes.c                          |Y1     | Anti-dependence within a single loop                                         | AutoPar    
DRD002-antidep1-var-yes.c                           |Y1     | Anti-dependence within a single loop                                         | AutoPar    
DRD003-antidep2-orig-yes.c                          |Y1     | Anti-dependence within a two-level loop nest                                 | AutoPar    
DRD004-antidep2-var-yes.c                           |Y1     | Anti-dependence within a two-level loop nest                                 | AutoPar    
DRD005-indirectaccess1-orig-yes.c                   |Y7     | Indirect access with overlapped index array elements                         | LLNL App   
DRD006-indirectaccess2-orig-yes.c                   |Y7     | Overlapping index array elements when 36 or more threads are used            | LLNL App   
DRD007-indirectaccess3-orig-yes.c                   |Y7     | Overlapping index array elements when 60 or more threads are used            | LLNL App   
DRD008-indirectaccess4-orig-yes.c                   |Y7     | Overlapping index array elements when 180 or more threads are used           | LLNL App   
DRD009-lastprivatemissing-orig-yes.c                |Y2     | Data race due to a missing `lastprivate()` clause                            | AutoPar    
DRD010-lastprivatemissing-var-yes.c                 |Y2     | Data race due to a missing `lastprivate()` clause                            | AutoPar    
DRD011-minusminus-orig-yes.c                        |Y3     | Unprotected decrement operation `--`                                         | AutoPar    
DRD012-minusminus-var-yes.c                         |Y3     | Unprotected decrement operation `--`                                         | AutoPar    
DRD013-nowait-orig-yes.c                            |Y3     | Missing barrier due to a wrongfully used nowait                              | AutoPar    
DRD014-outofbounds-orig-yes.c                       |Y6     | Out of bound access of the 2nd dimension of array                            | AutoPar    
DRD015-outofbounds-var-yes.c                        |Y6     | Out of bound access of the 2nd dimension of array                            | AutoPar    
DRD016-outputdep-orig-yes.c                         |Y1     | Output dependence and true dependence within a loop                          | AutoPar    
DRD017-outputdep-var-yes.c                          |Y1     | Output dependence and true dependence within a loop                          | AutoPar    
DRD018-plusplus-orig-yes.c                          |Y1     | increment operation `++` on array index variable                             | AutoPar    
DRD019-plusplus-var-yes.c                           |Y1     | increment operation `++` on array index variable                             | AutoPar    
DRD020-privatemissing-orig-yes.c                    |Y2     | Missing `private()` for a temp variable                                      | AutoPar    
DRD021-privatemissing-var-yes.c                     |Y2     | Missing `private()` for a temp variable                                      | AutoPar    
DRD022-reductionmissing-orig-yes.c                  |Y2     | Missing `reduction()` for a variable                                         | AutoPar    
DRD023-reductionmissing-var-yes.c                   |Y2     | Missing `reduction()` for a variable                                         | AutoPar    
DRD024-sections1-orig-yes.c                         |Y3     | Unprotected data writes in parallel sections                                 | New        
DRD025-simdtruedep-orig-yes.c                       |Y1,Y4  | SIMD instruction level data races                                            | New        
DRD026-simdtruedep-var-yes.c                        |Y1,Y4  | SIMD instruction level data races                                            | New        
DRD027-targetparallelfor-orig-yes.c                 |Y1,Y5  | Data races in loops offloaded to accelerators                                | New        
DRD028-taskdependmissing-orig-yes.c                 |Y3     | Unprotected data writes in two tasks                                         | New        
DRD029-truedep1-orig-yes.c                          |Y1     | True data dependence among multiple array elements within a single level loop| AutoPar    
DRD030-truedep1-var-yes.c                           |Y1     | True data dependence among multiple array elements within a single level loop| AutoPar    
DRD031-truedepfirstdimension-(orig&#124;var)-yes.c  |Y1     | True data dependence of first dimension for a 2-D array accesses             | AutoPar    
DRD032-truedepfirstdimension-(orig&#124;var)-yes.c  |Y1     | True data dependence of first dimension for a 2-D array accesses             | AutoPar    
DRD033-truedeplinear-orig-yes.c                     |Y1     | Linear equation as array subscript                                           | AutoPar    
DRD034-truedeplinear-var-yes.c                      |Y1     | Linear equation as array subscript                                           | AutoPar    
DRD035-truedepscalar-orig-yes.c                     |Y1     | True data dependence due to scalar                                           | AutoPar    
DRD036-truedepscalar-var-yes.c                      |Y1     | True data dependence due to scalar                                           | AutoPar    
DRD037-truedepseconddimension-(orig&#124;var)-yes.c |Y1     | True data dependence on 2nd dimension of a 2-D array accesses                | AutoPar    
DRD038-truedepseconddimension-(orig&#124;var)-yes.c |Y1     | True data dependence on 2nd dimension of a 2-D array accesses                | AutoPar    
DRD039-truedepsingleelement-(orig&#124;var)-yes.c   |Y1     | True data dependence due to a single array element                           | AutoPar    
DRD040-truedepsingleelement-(orig&#124;var)-yes.c   |Y1     | True data dependence due to a single array element                           | AutoPar    
DRD073-doall2-orig-yes.c                            |Y2     | Missing `private()` for inner loop nest's loop index variable                | New        
DRD074-flush-orig-yes.c                             |Y2     | Reduction using a shared variable, extracted from an official OpenMP example | New        
DRD075-getthreadnum-orig-yes.c                      |Y1     | Work sharing within one branch of a `if` statement                           | New        
DRD080-func-arg-orig-yes.c                          |Y6     | Function arguments passed by reference, inheriting shared attribute          | New        
DRD082-declared-in-func-orig-yes.c                  |Y6     | A variable declared within a function called by a parallel region            | New
DRD084-threadprivatemissing-orig-yes.c              |Y2     | Missing threadprivate for a global var, not referenced within a construct    | New
DRD086-static-data-member-orig-yes.cpp              |Y2     | Missing threadprivate for a static member, not referenced within a construct | New
DRD087-static-data-member2-orig-yes.cpp             |Y2     | Missing threadprivate for a static member, referenced within a construct     | New
DRD088-dynamic-storage-orig-yes.c                   |Y2     | Data race for a dynamica storage variable, not referenced within a construct | New
DRD089-dynamic-storage2-orig-yes.c                  |Y2     | Data race for a dynamica storage variable, referenced within a construct     | New
DRD090-static-local-orig-yes.c                      |Y2     | Data race for a locally declared static variable                             | New
DRD092-threadprivatemissing2-orig-yes.c             |Y2     | Missing threadprivate for a variable referenced within a construct           | New
DRD095-doall2-taskloop-orig-yes.c                   |Y2     | Missing protection for inner loop's loop variable                            | New
DRD106-taskwaitmissing-orig-yes.c                   |Y3     | Missing taskwait to ensure correct order of calculations                     | New
DRD109-orderedmissing-orig-yes.c                    |Y3     | Missing the ordered clause, causing data races                               | New
DRD111-linearmissing-orig-yes.c                     |Y2     | Missing linear for a shared variable, causing data races                     | New               
DRD114-if-orig-yes.c                                |Y1     | True data dependence within a single level loop, with if() clause            | New
DRD115-forsimd-orig-yes.c                           |Y1,Y4  | Both thread and instruction level data races due to omp loop simd            | New
DRD116-target-teams-orig-yes.c                      |Y3     | Master threads of two teams do not have synchronization, causing data races  | New

## Microbenchmarks without known data races

Microbenchmark                           |P-Label| Description                                                                          | Source     
-----------------------------------------|-------|--------------------------------------------------------------------------------------|------------
DRD041-3mm-parallel-no.c                 |N2     | 3-step matrix-matrix multiplication, non-optimized version                           | Polyhedral 
DRD042-3mm-tile-no.c                     |N2,N4  | 3-step matrix-matrix multiplication, with tiling and nested SIMD                     | Polyhedral 
DRD043-adi-parallel-no.c                 |N2     | Alternating Direction Implicit solver, non-optimized version                         | Polyhedral  
DRD044-adi-tile-no.c                     |N2,N4  | Alternating Direction Implicit solver, with tiling and nested SIMD                   | Polyhedral  
DRD045-doall1-orig-no.c                  |N1     | Classic DOAll loop operating on a one dimensional array                              | AutoPar    
DRD046-doall2-orig-no.c                  |N1     | Classic DOAll loop operating on a two dimensional array                              | AutoPar     
DRD047-doallchar-orig-no.c               |N1     | Classic DOALL loop operating on a character array                                    | New        
DRD048-firstprivate-orig-no.c            |N2     | Example use of firstprivate                                                          | AutoPar    
DRD049-fprintf-orig-no.c                 |N6     | Use of `fprintf()`                                                                   | New        
DRD050-functionparameter-orig-no.c       |N6     | Arrays passed as function parameters                                                 | LLNL App   
DRD051-getthreadnum-orig-no.c            |N2     | single thread execution using `if (omp_get_thread_num()==0)`                         | New              
DRD052-indirectaccesssharebase-orig-no.c |N7     | Indirect array accesses using index arrays without overlapping                       | LLNL App   
DRD053-inneronly1-orig-no.c              |N1     | Two-level nested loops, inner level is parallelizable. True dependence on outer level| AutoPar    
DRD054-inneronly2-orig-no.c              |N1     | Two-level nested loops, inner level is parallelizable. Anti dependence on outer level| AutoPar    
DRD055-jacobi2d-parallel-no.c            |N7     | Jacobi with array copying, no reduction, non-optimized version                       | Polyhedral 
DRD056-jacobi2d-tile-no.c                |N4,N7  | Jacobi with array copying, no reduction, with tiling and nested SIMD                 | Polyhedral 
DRD057-jacobiinitialize-orig-no.c        |N7     | The array initialization parallel loop in Jacobi                                     | AutoPar    
DRD058-jacobikernel-orig-no.c            |N7     | Parallel Jacobi stencil computation kernel with array copying and reduction          | AutoPar    
DRD059-lastprivate-orig-no.c             |N2     | Example use of lastprivate                                                           | AutoPar    
DRD060-matrixmultiply-orig-no.c          |N7     | Classic i-k-j order matrix multiplication using OpenMP                               | AutoPar    
DRD061-matrixvector1-orig-no.c           |N7     | Matrix-vector multiplication parallelized at the outer level loop                    | AutoPar    
DRD062-matrixvector2-orig-no.c           |N7     | Matrix-vector multiplication parallelized at the inner level loop with reduction     | AutoPar    
DRD063-outeronly1-orig-no.c              |N2     | Two-level nested loops, outer level is parallelizable. True dependence on inner level| AutoPar    
DRD064-outeronly2-orig-no.c              |N2     | Two-level nested loops, outer level is parallelizable. Anti dependence on inner level| AutoPar    
DRD065-pireduction-orig-no.c             |N7     | PI calculation using reduction                                                       | AutoPar    
DRD066-pointernoaliasing-orig-no.c       |N6     | Pointers assigned by different malloc calls, without aliasing                        | LLNL App   
DRD067-restrictpointer1-orig-no.c        |N6     | C99 restrict pointers used for array initialization, no aliasing                     | LLNL App    
DRD068-restrictpointer2-orig-no.c        |N6     | C99 restrict pointers used for array computation, no aliasing                        | LLNL App   
DRD069-sectionslock1-orig-no.c           |N3     | OpenMP parallel sections with a lock to protect shared data writes                   | New        
DRD070-simd1-orig-no.c                   |N1,N4  | OpenMP SIMD directive to indicate vectorization of a loop                            | New        
DRD071-targetparallelfor-orig-no.c       |N1,N5  | No data races in loops offloaded to accelerators                                     | New        
DRD072-taskdep1-orig-no.c                |N3     | OpenMP task with depend clauses to avoid data races                                  | New         
DRD076-flush-orig-no.c                   |N2     | OpenMP private clause to avoid data races                                            | New         
DRD077-single-orig-no.c                  |N1     | OpenMP single directive to use only one thread for execution                         | New
DRD078-taskdep2-orig-no.c                |N3     | OpenMP task depend clause to avoid data races                                        | New         
DRD079-taskdep3-orig-no.c                |N3     | OpenMP task depend clause to avoid data races                                        | New         
DRD081-func-arg-orig-no.c                |N6     | Function arguments passed by value, private                                          | New        
DRD083-declared-in-func-orig-no.c        |N6     | A variable declared within a function called by a parallel region                    | New
DRD085-threadprivate-orig-no.c           |N2     | Use threadprivate to protect a file scope variable, not referenced within a construct| New
DRD091-threadprivate2-orig-no.c          |N2     | Use threadprivate to protect a file scope variable, referenced within a construct    | New
DRD093-doall2-collapse-orig-no.c         |N2     | Use collapse(n) to control the number of associated loops of omp for                 | New
DRD094-doall2-ordered-orig-no.c          |N2     | Use ordered(n) to control the number of associated loops of omp for                  | New
DRD096-doall2-taskloop-collapse-orig-no.c|N2     | Use ordered(n) to control the number of associated loops of taskloop                 | New
DRD097-target-teams-distribute-orig-no.c |N2     | Predetermined attribute rule for loop variable associated with distribute            | New
DRD098-simd2-orig-no.c                   |N1,N2  | OpenMP SIMD directive to indicate vectorization of two nested loops                  | New        
DRD099-targetparallelfor2-orig-no.c      |N1,N5  | Loops offloaded to accelerators: array sections derived from pointer                 | New        
DRD100-task-reference-orig-no.cpp        |N1     | OpenMP 4.5 feature: orphaned task generating construct using pass-by-reference       | New
DRD101-task-value-orig-no.cpp            |N1     | In a task generating construct, a variable without applicable rules is firstprivate  | New
DRD102-copyprivate-orig-no.c             |N2     | threadprivate+copyprivate, a variable without applicable rules is firstprivate       | New
DRD103-master-orig-no.c                  |N1     | master directive to ensure only one thread will execute data accesses                | New
DRD104-nowait-barrier-orig-no.c          |N3     | Use barrier to ensure correct order of initialization and assignment phases          | New
DRD105-taskwait-orig-no.c                |N3     | Use taskwait to ensure correct order of tasks                                        | New
DRD107-taskgroup-orig-no.c               |N3     | Use taskgroup to ensure correct order of tasks                                       | New
DRD108-atomic-orig-no.c                  |N3     | Use atomic to protect shared accesses to a variable                                  | New
DRD110-ordered-orig-no.c                 |N3     | Proper use of the ordered clause to avoid data races                                 | New
DRD112-linear-orig-no.c                  |N2     | Use linear to privatize a variable                                                   | New
DRD113-default-orig-no.c                 |N1     | default(none) to enforce explicitly listing variables in data-sharing clauses        | New

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
