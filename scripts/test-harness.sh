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

CSV_HEADER="tool,id,filename,haverace,threads,dataset,races,elapsed-time(seconds),used-mem(KBs),compile-return,runtime-return"
TESTS=($(grep -l main micro-benchmarks/*.c micro-benchmarks/*.cpp))
FORTRANTESTS=($(find micro-benchmarks-fortran -iregex ".*\.F[0-9]*" -o -iregex ".*\.for"))
OUTPUT_DIR="results"
LOG_DIR="$OUTPUT_DIR/log"
INSPECTOR_LOG_DIR="$LOG_DIR/inspector"
EXEC_DIR="$OUTPUT_DIR/exec"
LOGFILE="$LOG_DIR/dataracecheck.log"
LANGUAGE="default"

PYTHON=${PYTHON:-"python3"}
LOGPARSER="scripts/log-parser/logParser.py"

MEMCHECK=${MEMCHECK:-"/usr/bin/time"}
TIMEOUTCMD=${TIMEOUTCMD:-"timeout"}
VALGRIND=${VALGRIND:-"valgrind"}
VALGRIND_COMPILE_C_FLAGS="-O0 -g -std=c99 -fopenmp"
VALGRIND_COMPILE_CPP_FLAGS="-O0 -g -fopenmp"

CLANG=${CLANG:-"clang"}
TSAN_COMPILE_FLAGS="-O0 -fopenmp -fsanitize=thread -g"

# Path to LLOV is fixed due to it's only available in container
LLOV_COMPILER="/home/llvm/Work/LLOV"
LLOV_COMPILE_FLAGS=" -Xclang -load -Xclang $LLOV_COMPILER/lib/OpenMPVerify.so"
LLOV_COMPILE_FLAGS+=" -Xclang -disable-O0-optnone"
LLOV_COMPILE_FLAGS+=" -fopenmp -fopenmp-version=45"
LLOV_COMPILE_FLAGS+=" -mllvm -polly-process-unprofitable"
LLOV_COMPILE_FLAGS+=" -mllvm -polly-invariant-load-hoisting"
LLOV_COMPILE_FLAGS+=" -mllvm -polly-ignore-parameter-bounds"
LLOV_COMPILE_FLAGS+=" -mllvm -polly-dependences-on-demand"
LLOV_COMPILE_FLAGS+=" -mllvm -polly-precise-fold-accesses"
#LLOV_COMPILE_FLAGS+=" -mllvm -openmp-verify-disable-aa"
LLOV_COMPILE_FLAGS+=" -O0 -g"

# Path to LLOV is fixed due to it's only available in container
FLANG_PATH=/home/llvm/installs/flang-2020-03-16

ARCHER=${ARCHER:-"clang-archer"}
ARCHER_COMPILE_FLAGS="-O0 -larcher"

INSPECTOR=${INSPECTOR:-"inspxe-cl"}
ICC_COMPILE_FLAGS="-O0 -fopenmp -std=c99 -qopenmp-offload=host -g"
ICPC_COMPILE_FLAGS="-O0 -fopenmp -qopenmp-offload=host -g"

ROMP_CPP_COMPILE_FLAGS="-O0 -g -std=c++11 -fopenmp -lomp"
ROMP_C_COMPILE_FLAGS="-O0 -g -fopenmp -lomp"

FORTRAN_LINK_FLAGS="-ffree-line-length-none -fopenmp -c -fsanitize=thread"
FORTRAN_COMPILE_FLAGS="-O0 -fopenmp -fsanitize=thread -lgfortran"
IFORT_FORTRAN_FLAGS="-g -O0 -free -qopenmp -qopenmp-offload=host -Tf"


POLYFLAG="micro-benchmarks/utilities/polybench.c -I micro-benchmarks -I micro-benchmarks/utilities -DPOLYBENCH_NO_FLUSH_CACHE -DPOLYBENCH_TIME -D_POSIX_C_SOURCE=200112L"
FPOLYFLAG="-Imicro-benchmarks-fortran micro-benchmarks-fortran/utilities/fpolybench.o"
VARLEN_PATTERN='[[:alnum:]]+-var-[[:alnum:]]+\.c'
RACES_PATTERN='[[:alnum:]]+-[[:alnum:]]+-yes\.c'
CPP_PATTERN='[[:alnum:]]+\.cpp'
F_PATTERN='[[:alnum:]]+\.f95'
F_VARLEN_PATTERN='[[:alnum:]]+-var-[[:alnum:]]+\.f95'
F_RACES_PATTERN='[[:alnum:]]+-[[:alnum:]]+-yes\.f95'

usage () {
  echo
  echo "Usage: $0 [--help] [OPTIONS]"
  echo "  --help    : Show usage and options"
  echo
  echo "OPTIONS:"
  echo "  -x tool       : Add the specified tool to test set."
  echo "                  Value can be one of: gnu, clang, intel, helgrind, tsan-clang, tsan-gcc, archer, inspector, inspector-max-resources, romp."
  echo "  -n iterations : Run each setting the specified number of iterations."
  echo "  -t threads    : Add the specified number of threads as a testcase."
  echo "  -d size       : Add a specific dataset size to the varlen test suite."
  echo "  -s minutes    : Add a specific timeout minutes."
  echo "  -l language   : Add a specific language test"
  echo "  -c customized : Add a customized test list"
  echo
}

valid_tool_name () {
  case "$1" in
    gnu) return 0 ;;
    clang) return 0 ;;
    intel) return 0 ;;
    helgrind) return 0 ;;
    archer) return 0 ;;
    coderrect) return 0 ;;
    tsan-clang) return 0 ;;
    tsan-gcc) return 0 ;;
    inspector) return 0 ;;
    inspector-max-resources) return 0 ;;
    romp) return 0;;   
    llov) return 0;;   
    *) return 1 ;;
  esac
}

valid_language_name () {
  case "$1" in
    c/c++) return 0 ;;
    C/C++) return 0 ;;
    c) return 0 ;;
    C) return 0 ;;
    c++) return 0 ;;
    C++) return 0 ;;
    fortran) return 0 ;;
    Fortran) return 0 ;;
    FORTRAN) return 0 ;;
    *) return 1 ;;
  esac
}

check_return_code () {
  case "$1" in
    11) echo "Seg Fault"; testreturn=11 ;;
    124) echo "Executime timeout";testreturn=124  ;;
    139) echo "Seg Fault"; testreturn=11 ;;
    *) testreturn=0  ;;
  esac
}

generateCSV () {
  echo "$tool,$id,\"$testname\",$haverace,${thread:-"N/A"},${size:-"N/A"},${races:-0},"N/A","N/A",${compilereturn:-1},"N/A"" >> "$file"
}

if [[ "$1" == "--help" ]]; then
  usage && exit 0;
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$EXEC_DIR"

TOOLS=()
DATASET_SIZES=()
THREADLIST=()
ITERATIONS=0
TIMEOUTMIN="5"
# Parse options
while getopts "n:t:x:d:s:l:c:" opt; do
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
    s)  if [[ ${OPTARG} -gt 0 ]]; then TIMEOUTMIN=(${OPTARG})
        else echo "timeout must be greater than 0" && usage && exit 1;
        fi ;;
    l)  if valid_language_name "${OPTARG}"; then LANGUAGE=${OPTARG};
        else echo "Invalid language name ${OPTARG}" && help && exit 1;
        fi ;;
    c)  if [[ ${OPTARG} -eq 1 ]]; then
            if [[ "$LANGUAGE" == "c" || "$LANGUAGE" == "C" || "$LANGUAGE" == "c++" || "$LANGUAGE" == "C++" ]]; then
                TEST=($(cat list.def));
                for tests in "${TEST[@]}"; do
                         CTEST+=("micro-benchmarks/$tests")
                 done
                 TESTS=("${CTEST[@]}")
            else
                 TEST=($(cat list.def));
                 for tests in "${TEST[@]}"; do
                         CTEST+=("micro-benchmarks-fortran/$tests")
                 done

                 FORTRANTESTS=("${CTEST[@]}")
            fi
        fi;;
  esac
done

# Set default values
if [[ ! ${#TOOLS[@]} -gt 0 ]]; then
  echo "Default tool set will be used: gnu, clang, intel helgrind, tsan-clang, tsan-gcc, archer, inspector-max-resources."
  TOOLS=( 'gnu' 'clang' 'intel' 'helgrind' 'tsan-clang' 'tsan-gcc' 'archer' 'inspector-max-resources' )
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
  echo "Default number of iterations will be used: 3"
  ITERATIONS=3
else
  echo "Iterations: ${ITERATIONS}";
fi

if [[ ! $TIMEOUTMIN -gt 0 ]]; then
  echo "Default timeout will be 5 minutes"
  TIMEOUTMIN=5
else
  echo "Timeout minutes: ${TIMEOUTMIN}";
fi

if [[ -e "$LOGFILE" ]]; then rm "$LOGFILE"; fi

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
  if [[ -e $exname ]]; then rm "$exname"; fi
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

if [[ "$LANGUAGE" == "c" || "$LANGUAGE" == "C" || "$LANGUAGE" == "c++" || "$LANGUAGE" == "C++" ]]; then

for tool in "${TOOLS[@]}"; do

  MEMLOG="$LOG_DIR/$tool.memlog"
  file="$OUTPUT_DIR/$tool.csv"
  echo "Saving to: $file and $MEMLOG"
  [ -e "$file" ] && rm "$file"
  echo "$CSV_HEADER" >> "$file"

  runtime_flags=''
  case "$tool" in
    'inspector-max-resources')
      runtime_flags+=" -collect ti3 -knob scope=extreme -knob stack-depth=16 -knob use-maximum-resources=true"
      tool='inspector'
      mkdir -p "$INSPECTOR_LOG_DIR"
      ;;
    'inspector')
      runtime_flags+=" -collect ti2"
      mkdir -p "$INSPECTOR_LOG_DIR"
      ;;
  esac

  TEST_INDEX=0
  for test in "${TESTS[@]}"; do
	  echo "test is $test"
    additional_compile_flags=''
    if [[ "$test" =~ $RACES_PATTERN ]]; then haverace=true; else haverace=false; fi
    if [[ "$test" =~ $VARLEN_PATTERN ]]; then SIZES=("${DATASET_SIZES[@]}"); else SIZES=(''); fi
    testname=$(basename $test)
    id=${testname#DRB}
    id=${id%%-*}
    echo "$test has $testname and ID=$id"

    # Compile
    exname="$EXEC_DIR/$(basename "$test").$tool.out"
    rompexec="$exname.inst"
    compilelog="$LOG_DIR/$(basename "$test").$tool.${ITER}_comp.log"
    logname="$(basename "$test").$tool.log"
    inspectorLogDir="$(basename "$test").$tool"
    jsonlogname="$(basename "$test").$tool.json"
    if [[ -e "$LOG_DIR/$logname" ]]; then rm "$LOG_DIR/$logname"; fi
    if grep -q 'PolyBench' "$test"; then additional_compile_flags+=" $POLYFLAG"; fi

    if [[ "$test" =~ $CPP_PATTERN ]]; then
      echo "testing C++ code:$test"
      case "$tool" in 
        gnu)        g++ -g -fopenmp $additional_compile_flags $test -o $exname -lm ;;
        clang)      clang++ -fopenmp -g $additional_compile_flags $test -o $exname -lm ;;
        intel)      icpc $ICPC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        helgrind)   g++ $VALGRIND_COMPILE_CPP_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        archer)     clang-archer++ $ARCHER_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        coderrect)  coderrect -XbcOnly clang++ -fopenmp -fopenmp-version=45 -g -O0 $additional_compile_flags $test -o $exname -lm > /dev/null 2>&1 ;;
        tsan-clang) clang++ $TSAN_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        tsan-gcc)   g++ $TSAN_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        llov)       $LLOV_COMPILER/bin/clang++ $LLOV_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm 2> $compilelog;;
        inspector)  icpc $ICPC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        romp)       g++ $ROMP_CPP_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm;
                    echo $exname
                    InstrumentMain --program=$exname;
      esac
    else
      case "$tool" in 
        gnu)        gcc -g -std=c99 -fopenmp $additional_compile_flags $test -o $exname -lm ;;
        clang)      clang -fopenmp -g $additional_compile_flags $test -o $exname -lm ;;
        intel)      icc $ICC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        helgrind)   gcc $VALGRIND_COMPILE_C_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        archer)     clang-archer $ARCHER_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        coderrect)  coderrect -XbcOnly clang -fopenmp -fopenmp-version=45 -g -O0 $additional_compile_flags $test -o $exname -lm  > /dev/null 2>&1 ;;
        tsan-clang) clang $TSAN_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        tsan-gcc)   gcc $TSAN_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        llov)       $LLOV_COMPILER/bin/clang $LLOV_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm 2> $compilelog;;
        inspector)  icc $ICC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;;
        romp)       gcc $ROMP_C_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm;
                    echo $exname
                    InstrumentMain --program=$exname;
      esac
    fi
    compilereturn=$?; 
    echo "compile return code: $compilereturn";

    if [[ $tool == llov ]] ; then
      echo "llov checking";
      races=$(grep -ce 'Data Race detected.' $compilelog);
      racefree=$(grep -ce 'Region is Data Race Free.' $compilelog);
      if [[ $compilereturn -gt 0  ||  $races -eq 0  &&  $racefree -eq 0 ]]; then
          races="NA"
      fi
      rm -f $exname
      generateCSV
      # Static Tool
      continue
    fi

    THREAD_INDEX=0
    for thread in "${THREADLIST[@]}"; do
      echo "Testing $test: with $thread threads"
      export OMP_NUM_THREADS=$thread 
      SIZE_INDEX=0
      for size in "${SIZES[@]}"; do
        # Sanity check
        if [[ ! -e "$exname" || $compilereturn -ne 0 ]]; then
          echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},0,0,0,$compilereturn,0" >> "$file";
          echo "Executable for $testname with $thread threads and input size $size is not available" >> "$LOGFILE";
        elif { "./$exname $size"; } 2>&1 | grep -Eq 'Segmentation fault'; then
            echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},,,,$compilereturn," >> "$file";
            echo "Seg fault found in $testname with $thread threads and input size $size" >> "$LOGFILE";
        else
          ITER_INDEX=1
          for ITER in $(seq 1 "$ITERATIONS"); do
            echo -e "*****     Log $ITER_INDEX for $testname with $thread threads and input size $size     *****" >> "$LOG_DIR/$logname"
            start=$(date +%s%6N)
            case "$tool" in
              gnu)
                #races=$($TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		;&
              clang)
                #races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		;&
              intel)
                #races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		$TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
		check_return_code $?;
                echo "$testname return $testreturn";
                races="",
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              helgrind)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" $VALGRIND  --tool=helgrind "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" $VALGRIND  --tool=helgrind "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'Possible data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              archer)
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                $PYTHON $LOGPARSER --tool archer tmp.log > $LOG_DIR/$jsonlogname
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              coderrect)
                ccc="clang"
                if [[ "$test" =~ $CPP_PATTERN ]]; then
                  ccc="clang++"
                fi
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" coderrect -XenableProgress=false -t $ccc -fopenmp -fopenmp-version=45 $additional_compile_flags $test -o $exname -lm &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'Found a data race' tmp.log)
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              tsan-clang)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" env TSAN_OPTIONS="exitcode=0 ignore_noninstrumented_modules=1" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              tsan-gcc)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              inspector)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" $INSPECTOR $runtime_flags -- "./$exname" $size  2>&1 | tee -a "$LOG_DIR/$logname" | grep 'Data race' | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/') ;;
		$TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" $INSPECTOR $runtime_flags -result-dir $INSPECTOR_LOG_DIR/$inspectorLogDir-$ITER  -- "./$exname" $size &> tmp.log;
		check_return_code $?;
                echo "$testname return $testreturn";
                $INSPECTOR -report problems -result-dir $INSPECTOR_LOG_DIR/$inspectorLogDir-$ITER -report-output $INSPECTOR_LOG_DIR/$logname
#                races=$(grep 'Data race' tmp.log | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/');
                races=$(grep -E '^P[0-9]+' $INSPECTOR_LOG_DIR/$logname  | wc -l)
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              romp)
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$rompexec" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'data race found:' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
                #races=$("./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'race found!') ;;
            esac
            end=$(date +%s%6N)
            elapsedtime=$(echo "scale=3; ($end-$start)/1000000"|bc)
            mem=$(cat $MEMLOG)
            echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},${races:-0},$elapsedtime,$mem,$compilereturn,$testreturn" >> "$file"
            ITER_INDEX=$((ITER_INDEX+1))
          done
        fi
        SIZE_INDEX=$((SIZE_INDEX+1))
      done
      THREAD_INDEX=$((THREAD_INDEX+1))
    done
    TEST_INDEX=$((TEST_INDEX+1))
    #if [[ -e $exname ]]; then rm "$exname"; fi
  done
  TOOL_INDEX=$((TOOL_INDEX+1))
done

elif [[ "$LANGUAGE" == "fortran" || "$LANGUAGE" == "FORTRAN" ]]; then

for tool in "${TOOLS[@]}"; do

  MEMLOG="$LOG_DIR/$tool.memlog"
  file="$OUTPUT_DIR/$tool.csv"
  echo "Saving to: $file and $MEMLOG"
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
  for test in "${FORTRANTESTS[@]}"; do
    additional_compile_flags=''
    if [[ "$test" =~ $F_RACES_PATTERN ]]; then haverace=true; else haverace=false; fi
    if [[ "$test" =~ $F_VARLEN_PATTERN ]]; then SIZES=("${DATASET_SIZES[@]}"); else SIZES=(''); fi
    testname=$(basename $test)
    id=${testname#DRB}
    id=${id%%-*}
    echo "$test has $testname and ID=$id"

    # Compile
    linkname="$EXEC_DIR/$testname.o"
    exname="$EXEC_DIR/$(basename "$test").$tool.out"
    rompexec="$exname.inst"
    compilelog="$LOG_DIR/$(basename "$test").$tool.${ITER}_comp.log"
    inspectorLogDir="$(basename "$test").$tool"
    logname="$(basename "$test").$tool.log"
    linklib=" "
    if [[ -e "$LOG_DIR/$logname" ]]; then rm "$LOG_DIR/$logname"; fi
    if grep -q 'PolyBench' "$test"; then additional_compile_flags+=" $FPOLYFLAG";gcc -c micro-benchmarks-fortran/utilities/fpolybench.c -o micro-benchmarks-fortran/utilities/fpolybench.o ; linklib+="micro-benchmarks-fortran/utilities/fpolybench.o"; fi

      echo "testing Fortran code:$test"
      case "$tool" in 
        gnu)        gfortran -fopenmp -lomp $additional_compile_flags $test -o $exname -lm ;;
        intel)      ifort $IFORT_FORTRAN_FLAGS  $test -o $exname -lm ;;
        tsan-clang) gfortran $FORTRAN_LINK_FLAGS $additional_compile_flags $test -o $linkname;
		    clang $FORTRAN_COMPILE_FLAGS $linkname $linklib -o $exname -lm;;
        tsan-gcc)   gfortran -fopenmp -fsanitize=thread $additional_compile_flags  $test -o $exname -lm  ;;
        archer)     gfortran $FORTRAN_LINK_FLAGS $additional_compile_flags $test -o $linkname;
	            clang-archer $FORTRAN_COMPILE_FLAGS $linkname $linklib -o $exname $ARCHER_COMPILE_FLAGS -lm;;
        coderrect)  coderrect -XbcOnly gfortran -O0 -g -fopenmp $additional_compile_flags $test -o $exname -lm > /dev/null 2>&1;
                    ls .coderrect/build/$exname.bc ;; # make $? to be 1 if coderrect could not compile the fortran case
        inspector)  ifort $IFORT_FORTRAN_FLAGS  $test -o $exname -lm ;;
        llov)       $FLANG_PATH/bin/flang -fopenmp -S -emit-llvm "$test" -o "$exname.ll";
                    $LLOV_COMPILER/bin/opt -mem2reg -O1 "$exname.ll" -S -o "$exname.ssa.ll";
                    $LLOV_COMPILER/bin/opt -load $LLOV_COMPILER/lib/OpenMPVerify.so \
                        -openmp-resetbounds "$exname.ssa.ll" -inline -S -o "$exname.resetbounds.ll";
                    $LLOV_COMPILER/bin/opt -load $LLOV_COMPILER/lib/OpenMPVerify.so \
                        -polly-detect-fortran-arrays -polly-process-unprofitable \
                        -polly-invariant-load-hoisting -polly-ignore-parameter-bounds \
                        -polly-dependences-on-demand -polly-precise-fold-accesses \
                        -disable-output \
                        -openmp-verify \
                        "$exname.resetbounds.ll" 2> $compilelog;
                    rm -f $exname.ll $exname.ssa.ll $exname.resetbounds.ll;;
        romp)       gfortran -O0 -g -fopenmp -lomp -ffree-line-length-none $additional_compile_flags $test -o $exname -lm;
                    echo $exname
                    InstrumentMain --program=$exname;;
      esac
    compilereturn=$?; 
    echo "compile return code: $compilereturn";

    if [[ $tool == llov ]] ; then
      races=$(grep -ce 'Data Race detected.' $compilelog);
      racefree=$(grep -ce 'Region is Data Race Free.' $compilelog);
      if [ $races -eq 0 ] && [ $racefree -eq 0 ]; then
          races="NA"
      fi
      rm -f $exname
      generateCSV
      # Static Tool
      continue
    fi

    THREAD_INDEX=0
    for thread in "${THREADLIST[@]}"; do
      echo "Testing $test: with $thread threads"
      export OMP_NUM_THREADS=$thread 
      SIZE_INDEX=0
      for size in "${SIZES[@]}"; do
        # Sanity check
        if [[ ! -e "$exname" || $compilereturn -ne 0 ]]; then
          echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},0,0,0,$compilereturn,0" >> "$file";
          echo "Executable for $testname with $thread threads and input size $size is not available" >> "$LOGFILE";
        elif { "./$exname $size"; } 2>&1 | grep -Eq 'Segmentation fault'; then
            echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},,,,$compilereturn," >> "$file";
            echo "Seg fault found in $testname with $thread threads and input size $size" >> "$LOGFILE";
        else
          ITER_INDEX=1
          for ITER in $(seq 1 "$ITERATIONS"); do
            echo -e "*****     Log $ITER_INDEX for $testname with $thread threads and input size $size     *****" >> "$LOG_DIR/$logname"
            start=$(date +%s%6N)
            case "$tool" in
              gnu)
                #races=$($TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		;&
              clang)
                #races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		;&
              intel)
                #races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
		$TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
		check_return_code $?;
                echo "$testname return $testreturn";
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              helgrind)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" $VALGRIND  --tool=helgrind "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" $VALGRIND  --tool=helgrind "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'Possible data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              archer)
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              coderrect)
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" coderrect -XenableProgress=false -t gfortran -fopenmp $additional_compile_flags $test -o $exname -lm &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'Found a data race' tmp.log)
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              tsan-clang)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" env TSAN_OPTIONS="exitcode=0 ignore_noninstrumented_modules=1" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              tsan-gcc)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;;
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$exname" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'WARNING: ThreadSanitizer: data race' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              inspector)
#                races=$($MEMCHECK -f "%M" -o "$MEMLOG" $INSPECTOR $runtime_flags -- "./$exname" $size  2>&1 | tee -a "$LOG_DIR/$logname" | grep 'Data race' | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/') ;;
		$TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" $INSPECTOR $runtime_flags -result-dir $INSPECTOR_LOG_DIR/$inspectorLogDir-$ITER  -- "./$exname" $size &> tmp.log;
		check_return_code $?;
                echo "$testname return $testreturn";
                $INSPECTOR -report problems -result-dir $INSPECTOR_LOG_DIR/$inspectorLogDir-$ITER -report-output $INSPECTOR_LOG_DIR/$logname
#                races=$(grep 'Data race' tmp.log | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/');
                races=$(grep -E '^P[0-9]+' $INSPECTOR_LOG_DIR/$logname  | wc -l)
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
              romp)
                $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" -o "$MEMLOG" "./$rompexec" $size &> tmp.log;
                check_return_code $?;
		echo "$testname return $testreturn"
                races=$(grep -ce 'data race found:' tmp.log) 
                cat tmp.log >> "$LOG_DIR/$logname" || >tmp.log ;;
                #races=$("./$exname" $size 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'race found!') ;;
            esac
            end=$(date +%s%6N)
            elapsedtime=$(echo "scale=3; ($end-$start)/1000000"|bc)
            mem=$(cat $MEMLOG)
            echo "$tool,$id,\"$testname\",$haverace,$thread,${size:-"N/A"},${races:-0},$elapsedtime,$mem,$compilereturn,$testreturn" >> "$file"
            ITER_INDEX=$((ITER_INDEX+1))
          done
        fi
        SIZE_INDEX=$((SIZE_INDEX+1))
      done
      THREAD_INDEX=$((THREAD_INDEX+1))
    done
    TEST_INDEX=$((TEST_INDEX+1))
    #if [[ -e $exname ]]; then rm "$exname"; fi
  done
  TOOL_INDEX=$((TOOL_INDEX+1))
done
fi
for tool in "${TOOLS[@]}"; do
	python3 scripts/metric.py $OUTPUT_DIR/$tool.csv
done
[ ! -f *.mod ] || rm *.mod
[ ! -d r*ti3 ] || rm -rf r*ti3
[ ! -f micro-benchmarks-fortran/utilities/fpolybench.o ] || rm micro-benchmarks-fortran/utilities/fpolybench.o
[ ! -f micro-benchmarks/utilities/polybench.o ] || rm micro-benchmarks/utilities/polybench.o
ulimit -s "$ULIMITS"
