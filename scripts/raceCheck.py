import json
import re
import os
import sys, getopt
import pandas as pd
import numpy as np


REF_DIR="references"
CDIR="C"
FDIR="Fortran"

TP,FP = (0,1)

pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 200)

def matchLineAndCol(gt, tool, id1, id2, r1, r2):
	return (gt.loc[id1, r1+"_line"] == tool.loc[id2, r2+"_line"] and 
	        #   tool reported column is in  the annotation range  ( column , column + len(dataname) + 1 )
		int(tool.loc[id2, r1+"_column"]) in range(int(gt.loc[id1, r2+"_column"]), int(gt.loc[id1, r2+"_column"])+len(gt.loc[id1, r2+"_dataname"])+2))

def evalTFP(vals):
	if vals[FP]:
		return "FP"
	if vals[TP]:
		return "TP"
	return "FN"

def queryandcompare(argv):
	#print(argv[0])
	sourceRace = pd.read_json(argv[0])
	sourceRace = sourceRace.transpose()
	# ref1 is always "W", whereas ref2 can be "R" or "W"
	sourceRace.loc[sourceRace['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref1_dataname','ref2_line','ref2_column','ref2_type','ref2_dataname']] = sourceRace.loc[sourceRace['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref2_dataname','ref1_line','ref1_column','ref1_type','ref1_dataname']].values
	print(sourceRace)
	toolReport = pd.read_json(argv[1])
	toolReport = toolReport.transpose()
	# we should force the format to keep only common essential columns
	if(len(toolReport)>0):
		toolReport = toolReport.drop(columns=['memAddr','ref1_thread','ref2_thread','ref2_filename'])
		toolReport.loc[toolReport['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = toolReport.loc[toolReport['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
		# For all the possible instances, we only care those with distinct loocation info.
		toolReport = toolReport.drop_duplicates()
	print(toolReport)

	# sourceRace['raceTypeMatch?'] = np.where((sourceRace['ref1_type'] == toolReport['ref1_type']) & (sourceRace['ref2_type'] == toolReport['ref2_type']), 'True', 'False')  #create new column in df1 to check if prices match
	
	typeMatchResult = [False,False]
	lineMatchResult = [False,False]
	colMatchResult = [False,False]
	

	if(len(toolReport)>0):
		for id2 in toolReport.index:
			typematchedFP = True
			linematchedFP = True
			colmatchedFP  = True
			for id1 in sourceRace.index:
				colmatched = linematched = typematched = (sourceRace.loc[id1, "ref1_type"] ==  toolReport.loc[id2, "ref1_type"]) & (sourceRace.loc[id1, "ref2_type"] ==  toolReport.loc[id2, "ref2_type"])
				if (typematched):
					typematchedFP = False
					typeMatchResult[TP] = True
				if( typematched & (sourceRace.loc[id1, "ref2_type"] == 'R')):
					linematched = (sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])
					colmatched = linematched & ((matchLineAndCol(sourceRace, toolReport, id1, id2, "ref1", "ref1") and
								     matchLineAndCol(sourceRace, toolReport, id1, id2, "ref2", "ref2")))
				elif( typematched & (sourceRace.loc[id1, "ref2_type"] == 'W')):
					linematched = (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"])))
					colmatched = linematched & ((matchLineAndCol(sourceRace, toolReport, id1, id2, "ref1", "ref1") and
								     matchLineAndCol(sourceRace, toolReport, id1, id2, "ref2", "ref2")) or
								    (matchLineAndCol(sourceRace, toolReport, id1, id2, "ref1", "ref2") and
								     matchLineAndCol(sourceRace, toolReport, id1, id2, "ref2", "ref1")))
				if (linematched):
					linematchedFP = False
					lineMatchResult[TP] = True
				if (colmatched):
					colmatchedFP = False
					colMatchResult[TP] = True
			if(typematchedFP):
				typeMatchResult[FP]=True
			if(linematchedFP):
				lineMatchResult[FP]=True
			if(colmatchedFP):
				colMatchResult[FP]=True

	print(evalTFP(typeMatchResult), evalTFP(lineMatchResult),evalTFP(colMatchResult)) 

if __name__ == "__main__":
	queryandcompare(sys.argv[1:])

