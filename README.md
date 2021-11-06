# DataRaceBench 1.4.0

DataRaceBench is a benchmark suite designed to systematically and
quantitatively evaluate the effectiveness of data race detection
tools. It includes a set of microbenchmarks with and without data
races. Parallelism is represented by OpenMP directives. OpenMP is a
popular parallel programming model for multi-threaded applications.

Note that some microbenchmarks use OpenMP 4.5 and 5.0 features. 
You may need a recent OpenMP compiler to compile them. 

DataRaceBench also comes with an evaluation script
(check-data-races.sh). The script can be used to evaluate the tools
Helgrind, Archer, Thread Sanitizer, Intel Inspector, and Coderrect Scanner. 
In addition a parameterized test harness (scripts/test-harness.sh) is 
available which allows to provide a number of different parameters for 
the evaluation. The test harness is used by the evaluation script with
some pre-defined values.

## Quick Start

```
./check-data-races.sh

Usage: ./check-data-races.sh [--run] [--help] language

--help      : this option
--small     : compile and test all benchmarks using small parameters with Helgrind, ThreadSanitizer, Archer, Intel inspector.
--run       : compile and run all benchmarks with gcc (no evaluation)
--run-intel : compile and run all benchmarks with Intel compilers (no evaluation)
--helgrind  : compile and test all benchmarks with Helgrind
--tsan-clang: compile and test all benchmarks with clang ThreadSanitizer
--tsan-gcc  : compile and test all benchmarks with gcc ThreadSanitizer
--archer    : compile and test all benchmarks with Archer
--coderrect : compile and test all benchmarks with Coderrect Scanner
--inspector : compile and test all benchmarks with Intel Inspector
--romp      : compile and test all benchmarks with Romp
--customize : compile and test customized test list and tools
```

More information: [User Guide](https://github.com/LLNL/dataracebench/blob/master/user_guide.md)

## Latest Tool Evaluation Results
[Data race detection tool dashboard](https://github.com/LLNL/dataracebench/wiki/Tool-Evaluation-Dashboard)

## List of Benchmarks

[Benchmark labels and lists - C/C++](https://github.com/LLNL/dataracebench/blob/master/benchmarkList.md)

[Benchmark labels and lists - Fortran](https://github.com/LLNL/dataracebench/blob/master/benchmarkListFortran.md)

## Authors

DataRaceBench was created by Chunhua Liao, Pei-Hung Lin, Gaurav Verma, Yaying Shi, Joshua Asplund, Markus Schordan, and Ian Karlin.

## Release

DataRaceBench is released under a BSD license. For more details see
the file LICENSE.txt. The microbenchmarks marked 'Polyhedral' in above
table were generated as optimization variants of benchmarks from the
PolyOpt benchmark suite. For those benchmarks see the license file
LICENSE.OSU.txt.

`LLNL-CODE-732144`

## How to Cite DataRaceBench in a Publication

If you are referring to DataRaceBench in a publication, please cite the following paper:

* Chunhua Liao, Pei-Hung Lin, Joshua Asplund, Markus Schordan, Ian Karlin.
[DataRaceBench: A Benchmark Suite for Systematic Evaluation of Data Race Detection Tools (best paper finalist)](https://dl.acm.org/citation.cfm?doid=3126908.3126958).
Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis, SC 2017, pp. 11:1-11:14, ISBN 978-1-4503-5114-0, Denver, CO, USA, November 12-17, 2017. [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/DataRaceBench-SC17.pdf)

If you use DataRaceBench v.1.4.0 or later, please additionally cite the following paper:
* Pei-Hung Lin and Chunhua Liao, High-Precision Evaluation of Both Static and Dynamic Tools using DataRaceBench, International Workshop on Software Correctness for HPC Applications (Correctness) SC21, 2021 [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/DataRaceBench_Correctness2021.pdf)
 
Other papers
* Chunhua Liao, Pei-Hung Lin, Markus Schordan and Ian Karlin, [A Semantics-Driven Approach to Improving DataRaceBench's OpenMP Standard Coverage](https://www.springerprofessional.de/en/a-semantics-driven-approach-to-improving-dataracebench-s-openmp-/16134302), IWOMP 2018: 14th International Workshop on OpenMP, Barcelona, Spain, September 26-28, 2018, [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/Semantics-DrivenImprovingCoverage-IWOMP2018.pdf), Version 1.2
* Pei-Hung Lin, Chunhua Liao, Markus Schordan, Ian Karlin. [Runtime and Memory Evaluation of Data Race Detection Tools](https://link.springer.com/chapter/10.1007/978-3-030-03421-4_13). ISoLA (2) 2018: 179-196. [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/2018-Runtime-Memory-Evaluation-DataRaceBench.pdf) 
* Pei-Hung Lin, Chunhua Liao, Markus Schordan, Ian Karlin. [Exploring Regression of Data Race Detection Tools Using DataRaceBench](https://ieeexplore.ieee.org/abstract/document/8951036). 2019 IEEE/ACM 3rd International Workshop on Software Correctness for HPC Applications (Correctness), Denver, CO, USA, 2019, pp. 11-18. [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/ExploringRegressionOfDataRaceDetectionTools-SC19.pdf), [Presentation](https://github.com/LLNL/dataracebench/blob/master/docs/2019-11-18-RegressionOfDataRaceTools-SC19.pdf)
* Gleison Souza Diniz Mendonça, Chunhua Liao, and Fernando Magno Quintão Pereira. AutoParBench: a unified test framework for OpenMP-based parallelizers. In Proceedings of the 34th ACM International Conference on Supercomputing (ICS '20). Association for Computing Machinery, New York, NY, USA, Article 28, 1–10.[pdf](https://github.com/LLNL/dataracebench/blob/master/docs/AutoParBench-ICS-2020.pdf)
* Gaurav Verma, Yaying Shi, Chunhua Liao, Barbara Chapman, and Yonghong Yan, [Enhancing DataRaceBench for Evaluating Data Race Detection Tools](https://ieeexplore.ieee.org/document/9296942), International Workshop on Software Correctness for HPC Applications (Correctness) SC20, 2020 [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/EnhancingDataRaceBench_SC_Correctness_2020.pdf), Version 1.3
* Yaying Shi, Anjia Wang, Yonghong Yan and Chunhua Liao, RDS: A Cloud-Based Metaservice for Detecting Data Races in Parallel Programs, 14th IEEE/ACM International Conference on Utility and Cloud Computing, University of Leicester, Leicester, UK, December 6-9, 2021 [pdf](https://github.com/LLNL/dataracebench/blob/master/docs/RaceDetectionService-UCC_2021.pdf)
