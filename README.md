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

## Quick Start

```
./check-data-races.sh 

Usage: ./check-data-races.sh [--run] [--help]

--help     : this option
--small    : compile and test all benchmarks using small parameters with Helgrind, ThreadSanitizer, Archer, Intel inspector.
--run      : compile and run all benchmarks with gcc (no evaluation)
--run-intel: compile and run all benchmarks with Intel compilers (no evaluation)
--helgrind : compile and test all benchmarks with Helgrind
--tsan     : compile and test all benchmarks with clang ThreadSanitizer
--archer   : compile and test all benchmarks with Archer
--inspector: compile and test all benchmarks with Intel Inspector

```

## Latest tool evaluation results
[Data race detection tool regression evaluation](https://github.com/LLNL/dataracebench/wiki/Regression-metrics)

## List of Benchmarks

[Benchmark labels and lists](https://github.com/LLNL/dataracebench/blob/master/benchmarkList.md)

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
Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis, SC 2017, pp. 11:1-11:14, ISBN 978-1-4503-5114-0, Denver, CO, USA, November 12-17, 2017. [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/DataRaceBench-SC17.pdf)

If you use DataRaceBench v.1.2.0 or later, please additionally cite the following paper discussing coverage analysis and improvements of the benchmark suite:

* Chunhua Liao, Pei-Hung Lin, Markus Schordan and Ian Karlin, [A Semantics-Driven Approach to Improving DataRaceBench's OpenMP Standard Coverage](https://www.springerprofessional.de/en/a-semantics-driven-approach-to-improving-dataracebench-s-openmp-/16134302), IWOMP 2018: 14th International Workshop on OpenMP, Barcelona, Spain, September 26-28, 2018, [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/Semantics-DrivenImprovingCoverage-IWOMP2018.pdf)

Other papers
* Pei-Hung Lin, Chunhua Liao, Markus Schordan, Ian Karlin. [Runtime and Memory Evaluation of Data Race Detection Tools](https://link.springer.com/chapter/10.1007/978-3-030-03421-4_13). ISoLA (2) 2018: 179-196.
* Pei-Hung Lin, Chunhua Liao, Markus Schordan, Ian Karlin. [Exploring Regression of Data Race Detection Tools Using DataRaceBench](https://ieeexplore.ieee.org/abstract/document/8951036). 2019 IEEE/ACM 3rd International Workshop on Software Correctness for HPC Applications (Correctness), Denver, CO, USA, 2019, pp. 11-18. [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/ExploringRegressionOfDataRaceDetectionTools-SC19.pdf), [Presentation](https://github.com/LLNL/dataracebench/blob/master/docs/2019-11-18-RegressionOfDataRaceTools-SC19.pdf)
