#!/usr/bin/env bash

# Copyright (c) 2017, Lawrence Livermore National Security, LLC.
# Produced at the Lawrence Livermore National Laboratory
# Written by Chunhua Liao, Pei-Hung Lin, Joshua Asplund,
# Markus Schordan, and Ian Karlin
# (email: liao6@llnl.gov, lin32@llnl.gov, asplund1@llnl.gov,
# schordan1@llnl.gov, karlin1@llnl.gov)
# LLNL-CODE-732144
# All rights reserved.
#
# This file is part of DataRaceBench. For details, see
# https://github.com/LLNL/dataracebench. Please also see the LICENSE file
# for our additional BSD notice
# 
# Redistribution of Backstroke and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the disclaimer below.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the disclaimer (as noted below)
#   in the documentation and/or other materials provided with the
#   distribution.
#
# * Neither the name of the LLNS/LLNL nor the names of its contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL LAWRENCE LIVERMORE NATIONAL
# SECURITY, LLC, THE U.S. DEPARTMENT OF ENERGY OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

OPTION=$1
TESTS=$(grep -l main micro-benchmarks/*.c)
POLYFLAG="micro-benchmarks/utilities/polybench.c -I micro-benchmarks -I micro-benchmarks/utilities -DPOLYBENCH_NO_FLUSH_CACHE -DPOLYBENCH_TIME -D_POSIX_C_SOURCE=200112L"

if [[ -z "$OPTION" || "$OPTION" == "--help" ]]; then
    echo
    echo "Usage: $0 [--run] [--help]"
    echo
    echo "--help     : this option"
    echo "--small    : compile and test all benchmarks using small parameters with Helgrind, ThreadSanitizer, Archer, Intel inspector."
    echo "--run      : compile and run all benchmarks with gcc (no evaluation)"
    echo "--helgrind : compile and test all benchmarks with Helgrind"
    echo "--tsan     : compile and test all benchmarks with clang ThreadSanitizer"
    echo "--archer   : compile and test all benchmarks with Archer"
    echo "--inspector: compile and test all benchmarks with Intel Inspector"
    echo
    exit
fi

if [[ "$OPTION" == "--small" ]]; then
  scripts/test-harness.sh -t 3 -n 2 -d 32 -x helgrind
  scripts/test-harness.sh -t 3 -n 2 -d 32 -x archer
  scripts/test-harness.sh -t 3 -n 2 -d 32 -x tsan
  scripts/test-harness.sh -t 3 -n 2 -d 32 -x inspector-max-resources
fi

if [[ "$OPTION" == "--run" ]]; then
    for test in $TESTS; do
        echo "------------------------------------------"
        echo "RUNNING: $test"
        CFLAGS="-g -Wall -std=c99 -fopenmp"
        if grep -q 'PolyBench' "$test"; then CFLAGS+=" $POLYFLAG"; fi
        gcc $CFLAGS "$test" -lm
        ./a.out  > /dev/null
    done
    rm -f ./a.out
    exit
fi

if [[ "$OPTION" == "--helgrind" ]]; then
    scripts/test-harness.sh -x helgrind
fi

if [[ "$OPTION" == "--archer" ]]; then
    scripts/test-harness.sh -x archer
fi

if [[ "$OPTION" == "--tsan" ]]; then
    scripts/test-harness.sh -x tsan
fi

if [[ "$OPTION" == "--inspector" ]]; then
    scripts/test-harness.sh -x inspector-max-resources
fi
