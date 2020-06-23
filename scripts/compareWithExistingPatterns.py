#!/usr/bin/env python3

"""
This is a script to compare a directory or a file with the existing patterns in the DRB.
It provides flags to pass a directory, a file, get maximum number of matches, and type
check for the *.c and *.f95/*.F95 files.
It extracts the #pragma omp or !$omp statements and compare for the longest common subsequence.
It then evaluates the matching value between 0 and 1, and reports top n matches.

Usage: python compareExistingPatterns.py [-f/-d] [filename_path/directory_path] -n [int] -t [c/f]
"""

import argparse
import gc
import itertools
import os
import re
import sys
from collections import defaultdict

import pylcs

# This is the path for the benchmark programs
DRB_PATH_FORTRAN = "../micro-benchmarks-fortran"
DRB_PATH_C = "../micro-benchmarks"


# Function to get patterns in a directory
def getPatternsDir(filePathToCheck):
    sub_str = defaultdict(list)
    for file in os.listdir(filePathToCheck):
        if file.endswith(".F95") or file.endswith(".f95"):
            with open(os.path.join(filePathToCheck, file), 'r') as _f:
                temp_list = list()
                for line in _f:
                    if re.findall(r'!\$[^\]]+', line):
                        line = line.replace("!$", "")
                        line = line.replace("omp", "")
                        line = line.replace("end", "")
                        temp_list.append(line.strip())
                sub_str[file].append(" ".join(temp_list))
        if file.endswith(".c"):
            with open(os.path.join(filePathToCheck, file), 'r') as _f:
                temp_list = list()
                for line in _f:
                    if "#pragma omp" in line:
                        line = line.replace("#pragma", "")
                        line = line.replace("omp", "")
                        line = line.replace("end", "")
                        temp_list.append(line.strip())
                sub_str[file].append(" ".join(temp_list))

    return (sub_str)


# Function to get patterns in a file
def getPatternsFile(filename):
    sub_str = defaultdict(list)
    temp_list = list()
    with open(filename, 'r') as _f:
        for line in _f:
            if re.findall(r'!\$[^\]]+', line):
                line = line.replace("!$", "")
                line = line.replace("omp", "")
                line = line.replace("end", "")
                filename = filename.split('/')[-1]
                temp_list.append(line.strip())
            if "#pragma omp" in line:
                line = line.replace("#pragma", "")
                line = line.replace("omp", "")
                line = line.replace("end", "")
                filename = filename.split('/')[-1]
                temp_list.append(line.strip())

    sub_str[filename].append(" ".join(temp_list))
    return sub_str


# Get the percentage similarity with the existing benchmark
def checkPatternSimilarity(parentPatternsDict, toCheckDict):
    if not toCheckDict:
        print("The new program doest not contain OpenMP Code")
        return -1

    _res = defaultdict(dict)

    for toCheckKey, toCheckValue in toCheckDict.items():
        for parKey, parValue in parentPatternsDict.items():
            lcs_len = pylcs.lcs(toCheckValue[0], parValue[0])
            lcs_perc = lcs_len / len(toCheckValue[0])
            _res[toCheckKey][parKey] = lcs_perc

    return _res


# Get the top n matching programs
def top_nmatch(dict, num):
    _res = {}
    for k, v in dict.items():
        _temp = [(kc, vc) for kc, vc in sorted(v.items(), key=lambda item: item[1], reverse=True)][:num]
        _res[k] = _temp

    return _res


# main function starts here
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compare pattern with the existing benchmark files."
                                                 "One of these two optional arguments is required")
    parser.add_argument("--dirpath", "-d", help="pass the dir path to compare", type=str, action='store')
    parser.add_argument("--filepath", "-f", help="pass the file path to compare", type=str, action='store')
    parser.add_argument("--nmatch", "-n", help="pass the num of matches to print", type=int, action='store')
    parser.add_argument("--filetype", "-t", help="pass the type of file", type=str, action='store')
    args = parser.parse_args()

    if not args.dirpath and not args.filepath:
        parser.print_help()

    try:
        if args.filetype == "c":
            _getParentPatternsDir = getPatternsDir(DRB_PATH_C)
        elif args.filetype == "f":
            _getParentPatternsDir = getPatternsDir(DRB_PATH_FORTRAN)
        else:
            print("Please provide either c/f as type -t")
            exit(1)

        if args.dirpath:
            _getPatternsDir = getPatternsDir(args.dirpath)
            res = checkPatternSimilarity(_getParentPatternsDir, _getPatternsDir)

        if args.filepath:
            _getPatternsFile = getPatternsFile(args.filepath)
            res = checkPatternSimilarity(_getParentPatternsDir, _getPatternsFile)

        if res == -1:
            exit(1)

        top_n_match = top_nmatch(res, args.nmatch)
        print(top_n_match)
    except:
        print("Error occurred. Check the log for more details.")
    else:
        print("Completed Successfully!")
    finally:
        gc.collect()
