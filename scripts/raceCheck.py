import json
import re
import os
import sys, getopt
import pandas as pd
import numpy as np


REF_DIR="references"
CDIR="C"
FDIR="Fortran"


def queryandcompare(argv):
	#print(argv[0])
	sourceRace = pd.read_json(argv[0])
	sourceRace = sourceRace.transpose()
	# ref1 is always "W", whereas ref2 can be "R" or "W"
	sourceRace.loc[sourceRace['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = sourceRace.loc[sourceRace['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
	print(sourceRace)
	toolReport = pd.read_json(argv[1])
	toolReport = toolReport.transpose()
	# we should force the format to keep only common essential columns
	toolReport = toolReport.drop(columns=['memAddr','ref1_thread','ref2_thread','ref2_filename'])
	toolReport.loc[toolReport['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = toolReport.loc[toolReport['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
	# For all the possible instances, we only care those with distinct loocation info.
	toolReport = toolReport.drop_duplicates()
	print(toolReport)

	# sourceRace['raceTypeMatch?'] = np.where((sourceRace['ref1_type'] == toolReport['ref1_type']) & (sourceRace['ref2_type'] == toolReport['ref2_type']), 'True', 'False')  #create new column in df1 to check if prices match
	
	for id1 in sourceRace.index:
		typematched = False
		linematched = False
		colmatched  = False
		for id2 in toolReport.index:
			typematched = (sourceRace.loc[id1, "ref1_type"] ==  toolReport.loc[id2, "ref1_type"]) & (sourceRace.loc[id1, "ref2_type"] ==  toolReport.loc[id2, "ref2_type"])
			if( typematched & (sourceRace.loc[id1, "ref2_type"] == 'R')):
				linematched = (sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])
				colmatched = linematched & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref1_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref2_column"])
			elif( typematched & (sourceRace.loc[id1, "ref2_type"] == 'W')):
				linematched = (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"])))
				colmatched = linematched & (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref1_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref2_column"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref2_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref1_column"])))
	

		print(typematched, linematched, colmatched) 

if __name__ == "__main__":
	queryandcompare(sys.argv[1:])

