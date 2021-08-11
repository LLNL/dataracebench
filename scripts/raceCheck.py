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
	sourceNum = sourceRace.shape[1]
	toolReport = pd.read_json(argv[1])
	ReportNum = toolReport.shape[1]
	#print(sourceNum,":", ReportNum)
	if ((sourceNum == 0) & (ReportNum == 0)) :
		print("0 : 0 : 0 , 0 : 0 : 0 , 0 : 0 : 0")
		return
	if ((sourceNum > 0) & (ReportNum == 0)) :
		# print("False negative report!")
		print(sourceNum, ": 0 : 0 ,", sourceNum, ": 0 : 0,", sourceNum, ": 0 : 0")
		#print("-1.0, -1.0, -1.0")
		return
	if ((sourceNum == 0) & (ReportNum > 0)) :
		# print("False positive report!")
		print("0 : 0 :", ReportNum,", 0 : 0 :", ReportNum,", 0 : 0 :",ReportNum)
		#print("-2.0, -2.0, -2.0")
		return

	sourceRace = sourceRace.transpose()
	# ref1 is always "W", whereas ref2 can be "R" or "W"
	sourceRace.loc[sourceRace['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = sourceRace.loc[sourceRace['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
	toolReport = toolReport.transpose()

	# Only process the common columns 
	intersect = sourceRace.columns.intersection(toolReport.columns)
#	print (intersect)
#	# we should force the format to keep only common essential columns
	sourceRace = sourceRace[intersect];
	if 'ref2_line' in sourceRace:
		sourceRace.sort_values(by=['ref1_line','ref2_line','ref2_type'])
	#print(sourceRace)
	toolReport = toolReport[intersect];
#	toolReport = toolReport.drop(columns=['memAddr','ref1_thread','ref2_thread','ref2_filename'])

	# To simplified later process, swap ref1 and ref2 to make ref1 to have only W type. 
	hasColumnInfo = False;
	if 'ref1_column' in toolReport:
		hasColumnInfo = True;
		toolReport.loc[toolReport['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = toolReport.loc[toolReport['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
	else:
		toolReport.loc[toolReport['ref1_type']=='R', ['ref1_line','ref1_type','ref2_line','ref2_type']] = toolReport.loc[toolReport['ref1_type']=='R',['ref2_line','ref2_type','ref1_line','ref1_type']].values

#	# For all the possible instances, we only care those with distinct loocation info.
	toolReport = toolReport.drop_duplicates()
	ReportNum = toolReport.shape[0]
	if 'ref2_line' in toolReport:
		toolReport.sort_values(by=['ref1_line','ref2_line','ref2_type'])
	#print(sourceRace)
	#print(toolReport)

	# sourceRace['raceTypeMatch?'] = np.where((sourceRace['ref1_type'] == toolReport['ref1_type']) & (sourceRace['ref2_type'] == toolReport['ref2_type']), 'True', 'False')  #create new column in df1 to check if prices match

	numTypeMatch = 0
	numLineMatch = 0
	numColMatch = 0
	# print(sourceRace.eq(toolReport))
	for id1 in sourceRace.index:
		typematched = False
		linematched = False
		colmatched  = False
		for id2 in toolReport.index:
			localtypematch = False
			locallinematch = False
			localcolumnmatch = False
			localtypematch = (sourceRace.loc[id1, "ref1_type"] ==  toolReport.loc[id2, "ref1_type"]) & (sourceRace.loc[id1, "ref2_type"] ==  toolReport.loc[id2, "ref2_type"])
			# if any case match, report it as matched
			# print(id1, id2,typematched,localtypematch)
			if typematched is False:
				typematched = localtypematch
			if( localtypematch & (sourceRace.loc[id1, "ref2_type"] == 'R')):
				locallinematch = (sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])
				if linematched is False:
					linematched = locallinematch
				#print("R",id1,id2,linematched, locallinematch, sourceRace.loc[id1, "ref1_line"], toolReport.loc[id2, "ref1_line"])
				# if a type and line match found by the tool, skip the rest and move to next source race checking
				if locallinematch:
					if hasColumnInfo:
						localcolumnmatch = locallinematch & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref1_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref2_column"])
						if colmatched is False:
							colmatched = localcolumnmatch
				# 	break
			elif( localtypematch & (sourceRace.loc[id1, "ref2_type"] == 'W')):
				locallinematch = (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"])))
				if linematched is False:
					linematched = locallinematch
				#print("W",id1,id2,linematched,locallinematch)
				if locallinematch:
					if hasColumnInfo:
						localcolumnmatch = locallinematch & (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref1_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref2_column"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref2_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref1_column"])))
						if colmatched is False:
							colmatched = localcolumnmatch
				#	break
			elif( (localtypematch is False)  & (toolReport.loc[id2, "ref1_type"] == 'N/A') &  (toolReport.loc[id2, "ref2_type"] == 'N/A') ):
				# Romp does not provide access type info in result.  We can only check line and column info.
				# print("ROMP output")
				locallinematch = (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"])))
				if linematched is False:
					linematched = locallinematch
				#print("Other",id1,id2,linematched,locallinematch, (localtypematch is False), (toolReport.loc[id2, "ref1_type"] == 'N/A'))
				if locallinematch:
					if hasColumnInfo:
						localcolumnmatch = locallinematch & (((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref1_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref2_column"])) | ((sourceRace.loc[id1, "ref1_line"] ==  toolReport.loc[id2, "ref2_line"]) & (sourceRace.loc[id1, "ref2_line"] ==  toolReport.loc[id2, "ref1_line"]) & (sourceRace.loc[id1, "ref1_column"] ==  toolReport.loc[id2, "ref2_column"]) & (sourceRace.loc[id1, "ref2_column"] ==  toolReport.loc[id2, "ref1_column"])))
						if colmatched is False:
							colmatched = localcolumnmatch
				#	break
	
		if typematched:
			numTypeMatch = numTypeMatch + 1
		if linematched:
			numLineMatch = numLineMatch + 1
		if colmatched:
			numColMatch = numColMatch + 1;
			
	#print(100*float(numTypeMatch)/float(sourceNum),",",100 * float(numLineMatch)/float(sourceNum),",", 100 * float(numColMatch)/float(sourceNum)) 
	print(sourceNum, ":", numTypeMatch,":",(ReportNum-numTypeMatch), ",", sourceNum, ":", numLineMatch, ":", (ReportNum-numLineMatch), "," ,sourceNum, ":", numColMatch, ":", (ReportNum-numColMatch))

if __name__ == "__main__":
	queryandcompare(sys.argv[1:])

