#!/usr/bin/env python3

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

import numpy as np
import pandas as pd

def result_type(row):
    result = ""
    if (row['haverace']) and (row['races-max'] > 0):
        result += '\\truepositive'
    if (row['haverace']) and (row['races-min'] == 0):
        result += '\\falsenegative'
    if (not row['haverace']) and (row['races-max'] > 0):
        result += '\\falsepositive'
    if (not row['haverace']) and (row['races-min'] == 0):
        result += '\\truenegative'
    return result

datasets = {
    'archer': ['results/archer-4.0.1-polyhedral.csv', 'results/archer-4.0.1-Quartz.csv']
  , 'helgrind': ['results/helgrind-polyhedral-Quartz.csv', 'results/helgrind-Quartz.csv']
  , 'inspector': ['results/inspector-polyhedral.csv', 'results/inspector-ti3-Quartz.csv']
  , 'tsan': ['results/tsan-4.0.1-Quartz.csv', 'results/tsan-4.0.1-polyhedral.csv']
  }

summary = pd.DataFrame(index=datasets.keys())
summary.index.name = 'tool'

for tool, dfs in datasets.items():
    dfs = [pd.read_csv(x) for x in dfs]
    results = pd.concat(dfs)

    tp = len(results[((results['haverace'] > 0) & (results['races'] > 0))])
    fn = len(results[((results['haverace'] > 0) & (results['races'] == 0))])
    fp = len(results[((results['haverace'] == 0) & (results['races'] > 0))])
    tn = len(results[((results['haverace'] == 0) & (results['races'] == 0))])

    summary.set_value(tool, 'recall', tp / (tp + fn))
    summary.set_value(tool, 'precision', tp / (tp + fp))
    summary.set_value(tool, 'accuracy', (tp + tn) / (tp + fp + fn + tn))

    race_min = results.groupby(['tool', 'filename', 'haverace']).min()
    race_max = results.groupby(['tool', 'filename', 'haverace']).max()
    output = race_min.join(race_max, lsuffix='-min', rsuffix='-max').reset_index()
    output[['races-min','races-max']] = output[['races-min','races-max']].astype(int)

    output['filename'] = output['filename'].str.split('/').str.get(1)
    output['haverace'] = output['haverace'] > 0
    output['found-race'] = output['races-max'] > 0
    output['type'] = output.apply(result_type, axis=1)

    outfile_local = 'results/{}-finished.csv'.format(tool)
    with open(outfile_local, "w") as f:
        output.to_csv(f, index=False)

    outfile = '../publications/sc17/{}-finished.csv'.format(tool)
    with open(outfile, "w") as f:
        output.to_csv(f, index=False)

with open('results/summary.csv', "w") as f:
    summary.to_csv(f)
