# License

## Experiments

All experiments are located in `/home/vboxuser/Desktop/sc4drf/experiments`. The
experiments consist of the following files from DataRaceBench:

    experiments/llov/micro-benchmarks/*.c
    experiments/llov/micro-benchmarks/polybench/*
    experiments/llov/micro-benchmarks/utilities/*
    experiments/civl/micro-benchmarks/*.c

DataRaceBench files are covered by the DataRaceBench license found in
`experiments/llov/micro-benchmarks/LICENSE.txt`, which allows
redistribution and use in source and binary forms, with or without
modification, under certain restrictions (3-clause BSD license).

We added new experiments and scripts to run the DataRaceBench experiments.
We release our own files under GPLv3 license. The files are located in

    experiments/civl/extras : all files
    experiments/llov/extras : all files
    experiments/civl/micro-benchmarks: Makefile, civl_out.txt, results_m1mac, summary.txt, times.txt
    experiments/llov/micro-benchmarks: Makefile, llov_expected_output.txt

## CIVL

The CIVL tool is located in `/home/vboxuser/CIVL` and is released under GPLv3 license. 
The license file can be found at `/home/vboxuser/CIVL/README`

CIVL depends on the following packages:

 - CVC4, which is licensed under a modified BSD licence available at
   https://github.com/CVC4/CVC4-archived/blob/master/COPYING
 - Z3, licensed under MIT license, see
   https://github.com/Z3Prover/z3/blob/master/LICENSE.txt
 - OpenJDK, licensed under GPLv2 with linking exception, see
   https://github.com/openjdk/jdk/blob/master/LICENSE

## LLOV

The license for LLOV can be found in `/home/vboxuser/LLOV-v0.3/LICENSE.txt` and
allows redistribution and reuse under a 4-clause BSD license.

## Ubuntu and other installed packages
The Ubuntu operating system and its installed packages are governed by
their respective licenses that allow redistribution and use under
certain restrictions. This includes the following packages that we installed
using the `apt` package manager during the preparation of this artifact.
They are not required to run the experiments.

 - ant
 - subversion
 - vim
 - grip
 - zerofree

We also installed the VirtualBox Guest Additions (under GPLv2 license) to
improve the usability of our artifact.

