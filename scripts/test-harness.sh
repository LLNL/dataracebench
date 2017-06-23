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

CSV_HEADER="tool,filename,haverace,threads,dataset,races,elapsed-time(seconds)"
TESTS=($(grep -l main micro-benchmarks/*.c))
OUTPUT_DIR="results"
LOGFILE="$OUTPUT_DIR/drfs.log"

VALGRIND=${VALGRIND:-"valgrind"}
VALGRIND_COMPILE_FLAGS="-g -std=c99 -fopenmp"

CLANG=${CLANG:-"clang"}
TSAN_COMPILE_FLAGS="-fopenmp -fsanitize=thread -g"

ARCHER=${ARCHER:-"clang-archer"}
ARCHER_COMPILE_FLAGS="-larcher"

INSPECTOR=${INSPECTOR:-"inspxe-cl"}
ICC_COMPILE_FLAGS="-O0 -fopenmp -std=c99 -qopenmp-offload=host"

POLYFLAG="micro-benchmarks/utilities/polybench.c -I micro-benchmarks -I micro-benchmarks/utilities -DPOLYBENCH_NO_FLUSH_CACHE -DPOLYBENCH_TIME -D_POSIX_C_SOURCE=200112L"

VARLEN_PATTERN='[[:alnum:]]+-var-[[:alnum:]]+\.c'
RACES_PATTERN='[[:alnum:]]+-[[:alnum:]]+-yes\.c'

usage () {
  echo
  echo "Usage: $0 [--help] [OPTIONS]"
  echo "  --help    : Show usage and options"
  echo
  echo "OPTIONS:"
  echo "  -x tool       : Add the specified tool to test set."
  echo "                  Value can be one of: helgrind, tsan, archer, inspector, inspector-max-resources."
  echo "  -n iterations : Run each setting the specified number of iterations."
  echo "  -t threads    : Add the specified number of threads as a testcase."
  echo "  -d size       : Add a specific dataset size to the varlen test suite."
  echo
}

valid_tool_name () {
  case "$1" in
    helgrind) return 0 ;;
    archer) return 0 ;;
    tsan) return 0 ;;
    inspector) return 0 ;;
    inspector-max-resources) return 0 ;;
    *) return 1 ;;
  esac
}

if [[ "$1" == "--help" ]]; then
  usage && exit 0;
fi

mkdir -p "$OUTPUT_DIR"

TOOLS=()
DATASET_SIZES=()
THREADLIST=()
ITERATIONS=0
# Parse options
while getopts "n:t:x:d:" opt; do
  case $opt in
    x)  if valid_tool_name "${OPTARG}"; then TOOLS+=(${OPTARG});
        else echo "Invalid tool name ${OPTARG}" && usage && exit 1
        fi ;;
    n)  if [[ ${OPTARG} -gt 0 ]]; then ITERATIONS=${OPTARG};
        else echo "Number of iterations must be greater than 0"
        fi ;;
    t)  if [[ ${OPTARG} -gt 1 ]]; then THREADLIST+=(${OPTARG})
        else echo "Number of threads must be greater than 1" && usage && exit 1;
        fi ;;
    d)  if [[ ${OPTARG} -gt 1 ]]; then DATASET_SIZES+=(${OPTARG})
        else echo "Dataset size must be greater than 1" && usage && exit 1;
        fi ;;
  esac
done

# Set default values
if [[ ! ${#TOOLS[@]} -gt 0 ]]; then
  echo "Default tool set will be used: helgrind, tsan, archer, inspector-max-resources."
  TOOLS=( 'helgrind' 'tsan' 'archer' 'inspector-max-resources' )
else
  echo "Tools: ${TOOLS[*]}";
fi

if [[ ! ${#DATASET_SIZES[@]} -gt 0 ]]; then
  echo "Default dataset sizes will be used: 32, 64, 128, 256, 512, 1024."
  DATASET_SIZES=('32' '64' '128' '256' '512' '1024')
else
  echo "Dataset sizes: ${DATASET_SIZES[*]}";
fi

if [[ ! ${#THREADLIST[@]} -gt 0 ]]; then
  echo "Default thread counts will be used: 3, 36, 45, 72, 90, 180, 256."
  THREADLIST=('3' '36' '45' '72' '90' '180' '256')
else
  echo "Thread counts: ${THREADLIST[*]}";
fi

if [[ ! $ITERATIONS -gt 0 ]]; then
  echo "Default number of iterations will be used: 5"
  ITERATIONS=5
else
  echo "Iterations: ${ITERATIONS}";
fi

if [[ ! -e "$LOGFILE" ]]; then touch "$LOGFILE"; fi

# Increase stack size - Fixes crashes in some analyses
ULIMITS=$(ulimit -s)
ulimit -s unlimited

TOOL_INDEX=0
TEST_INDEX=0
THREAD_INDEX=0
SIZE_INDEX=0
ITER=1

cleanup () {
  ulimit -s "$ULIMITS"
  if [[ -z ${exname+x} && -e $exname ]]; then rm "$exname"; fi
  echo "EXITING"
  echo "--------------------------" >> "$LOGFILE"
  echo "Unfinished tests:" >> "$LOGFILE"
  for tool in "${TOOLS[@]:$TOOL_INDEX}"; do
    if [[ $TEST_INDEX -eq 0 && $THREAD_INDEX -eq 0 && $SIZE_INDEX -eq 0 && $ITER -eq 1 ]]; then
      echo "$tool,all,all,all,$ITERATIONS" >> "$LOGFILE"
    else
      for test in "${TESTS[@]:$TEST_INDEX}"; do
        if [[ $THREAD_INDEX -eq 0 && $SIZE_INDEX -eq 0 && $ITER -eq 1 ]]; then
          echo "$tool,\"$test\",all,all,$ITERATIONS" >> "$LOGFILE"
        else
          for thread in "${THREADLIST[@]:$THREAD_INDEX}"; do
            if [[ $SIZE_INDEX -eq 0 && $ITER -eq 1 ]]; then
              echo "$tool,\"$test\",$thread,all,$ITERATIONS" >> "$LOGFILE"
            else
              for size in "${SIZES[@]:$SIZE_INDEX}"; do
                if [[ $ITER -eq 1 ]]; then echo "$tool,\"$test\",$thread,${size:-"N/A"},$ITERATIONS" >> "$LOGFILE"
                else echo "$tool,\"$test\",$thread,all,$((ITERATIONS - ITER + 1))" >> "$LOGFILE"; ITER=1; fi
              done
              SIZE_INDEX=0
            fi
          done
          THREAD_INDEX=0
        fi
      done
      TEST_INDEX=0
    fi
  done
  exit 1
}

trap cleanup SIGINT SIGTERM

for tool in "${TOOLS[@]}"; do

  file="$OUTPUT_DIR/$tool.csv"
  echo "Saving to: $file"
  [ -e "$file" ] && rm "$file"
  echo "$CSV_HEADER" >> "$file"

  runtime_flags=''
  case "$tool" in
    'inspector-max-resources')
      runtime_flags+=" -collect ti3 -knob scope=extreme -knob stack-depth=16 -knob use-maximum-resources=true"
      tool='inspector'
      ;;
    'inspector')
      runtime_flags+=" -collect ti2"
      ;;
  esac

  TEST_INDEX=0
  for test in "${TESTS[@]}"; do
    additional_compile_flags=''
    if [[ "$test" =~ $RACES_PATTERN ]]; then haverace=true; else haverace=false; fi
    if [[ "$test" =~ $VARLEN_PATTERN ]]; then SIZES=("${DATASET_SIZES[@]}"); else SIZES=(''); fi

    # Compile
    exname="a.out"
    if grep -q 'PolyBench' "$test"; then additional_compile_flags+=" $POLYFLAG"; fi

    case "$tool" in 
      helgrind)   gcc $VALGRIND_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
      archer)     clang-archer $ARCHER_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
      tsan)       clang $TSAN_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
      inspector)  icc $ICC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
    esac

    THREAD_INDEX=0
    for thread in "${THREADLIST[@]}"; do
      export OMP_NUM_THREADS=$thread 
      SIZE_INDEX=0
      for size in "${SIZES[@]}"; do
        # Sanity check
        if [[ ! -e "$exname" ]]; then
          echo "$tool,\"$test\",$haverace,$thread,${size:-"N/A"},Error,N/A" >> "$file";
          echo "Executable for $test with $thread threads and input size $size is not available" >> "$LOGFILE";
        elif { "./$exname $size"; } 2>&1 | grep -Eq 'Segmentation fault'; then
            echo "$tool,\"$test\",$haverace,$thread,${size:-"N/A"},Error,N/A" >> "$file";
            echo "Seg fault found in $test with $thread threads and input size $size" >> "$LOGFILE";
        else
          for ITER in $(seq 1 "$ITERATIONS"); do
            start=$(date +%s)
            case "$tool" in
              helgrind)
                races=$($VALGRIND  --tool=helgrind "./$exname" $size 2>&1 | grep -ce 'Possible data race') ;;
              archer)
                races=$("./$exname" $size 2>&1 | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
              tsan)
                races=$("./$exname" $size 2>&1 | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
              inspector)
                races=$($INSPECTOR $runtime_flags -- "./$exname" $size  2>&1 | grep 'Data race' | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/') ;;
            esac
            end=$(date +%s)
            echo "$tool,\"$test\",$haverace,$thread,${size:-"N/A"},${races:-0},$(( end - start ))" >> "$file"
          done
        fi
        SIZE_INDEX=$((SIZE_INDEX+1))
      done
      THREAD_INDEX=$((THREAD_INDEX+1))
    done
    TEST_INDEX=$((TEST_INDEX+1))
    if [[ -z ${exname+x} && -e $exname ]]; then rm "$exname"; fi
  done
  TOOL_INDEX=$((TOOL_INDEX+1))
done

ulimit -s "$ULIMITS"
