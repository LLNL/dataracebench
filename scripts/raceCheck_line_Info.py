import json
import re
import os
import sys, getopt
import pandas as pd
import numpy as np
import itertools


def getsource(sourcePath):
	sourceRace = pd.read_json(sourcePath)
	sourceNum = sourceRace.shape[1]
	if((sourceNum != 0)):
		sourceRace = sourceRace.transpose()
		#print(sourceRace)
		# ref1 is always "W", whereas ref2 can be "R" or "W"
		sourceRace.loc[sourceRace['ref1_type']=='R', ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = sourceRace.loc[sourceRace['ref1_type']=='R',['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
		sourceRace.loc[(sourceRace['ref1_type']=='W') & (sourceRace['ref1_line'] > sourceRace['ref2_line']), ['ref1_line','ref1_column','ref1_type','ref2_line','ref2_column','ref2_type']] = sourceRace.loc[(sourceRace['ref1_type']=='W') & (sourceRace['ref1_line'] > sourceRace['ref2_line']),['ref2_line','ref2_column','ref2_type','ref1_line','ref1_column','ref1_type']].values
		sourceRace.sort_values(by=['ref1_line','ref2_line','ref2_type'],inplace=True)
		sourceRace = sourceRace[['microbenchmark','ref1_line','ref2_line']]
	return sourceRace

def getTooReport(reportPath):
	print("process "+ reportPath)
	if(not os.path.isfile(reportPath)):
		print(reportPath + " not available")
		my_df  = pd.DataFrame()
		return my_df 
	toolReport = pd.read_json(reportPath)
	ReportNum = toolReport.shape[1]
	if((ReportNum != 0)):
		toolReport = toolReport.transpose()
		toolReport = toolReport.dropna()
		if not ('ref2_filename' in toolReport):
			df = pd.DataFrame()
			return	df
		if(toolReport['ref1_filename'].equals(toolReport['ref2_filename'])):
			toolReport.drop(columns=['ref2_filename'],inplace=True)
			toolReport.rename(columns={'ref1_filename':'microbenchmark'},inplace=True)
		if ('memAddr' in toolReport):
			toolReport.drop(columns=['memAddr'],inplace=True)
		if ('ref1_column' in toolReport):
			toolReport.drop(columns=['ref1_column','ref2_column'],inplace=True)
		if ('ref1_thread' in toolReport):
			toolReport.drop(columns=['ref1_thread','ref2_thread'],inplace=True)
		if ('ref2_line' in toolReport):
			if ('ref2_type' in toolReport):
				toolReport.sort_values(by=['ref1_line','ref2_line','ref2_type'],inplace=True)
			else:
				toolReport.sort_values(by=['ref1_line','ref2_line'],inplace=True)

	#	# To simplified later process, swap ref1 and ref2 to make ref1 to have only W type. 
		if  ('ref1_type' in toolReport):
			toolReport.loc[toolReport['ref1_type']=='R', ['ref1_line','ref1_type','ref2_line','ref2_type']] = toolReport.loc[toolReport['ref1_type']=='R',['ref2_line','ref2_type','ref1_line','ref1_type']].values
			toolReport.loc[(toolReport['ref1_type']=='W') & (toolReport['ref1_line'] > toolReport['ref2_line']), ['ref1_line','ref1_type','ref2_line','ref2_type']] = toolReport.loc[(toolReport['ref1_type']=='W') & (toolReport['ref1_line'] > toolReport['ref2_line']),['ref2_line','ref2_type','ref1_line','ref1_type']].values
		toolReport = toolReport.drop_duplicates()
	return toolReport

def checkRace(sourceRace, toolReport):
	if  ('ref1_type' in sourceRace):
		sourceRace.drop(columns=['ref1_type','ref2_type'],inplace=True)
	if  ('ref1_type' in toolReport):
		toolReport.drop(columns=['ref1_type','ref2_type'],inplace=True)
	intersect = sourceRace.columns.intersection(toolReport.columns)
	#print (len(intersect))
	if((len(intersect) != 0)):
		sourceRace = sourceRace[intersect];
		toolReport = toolReport[intersect];
	
	sourceRace = sourceRace.drop_duplicates()
	toolReport = toolReport.drop_duplicates()

	sourceNum = len(sourceRace)
	ReportNum = len(toolReport)
	#print("sourceRace")
	#print(sourceRace)
	#print("toolReport")
	#print(toolReport)

	# report will be TP, FN, TN, FP
	if ((sourceNum == 0) & (ReportNum == 0)) :
		#print(0,1,0,0)
		return [0,0,1,0]	
	elif ((sourceNum > 0) & (ReportNum == 0)) :
		#print(0,sourceNum,0,0)	
		return [0,sourceNum,0,0]
	elif ((sourceNum == 0) & (ReportNum > 0)) :
		toolReport = toolReport.drop_duplicates()
		ReportNum = len(toolReport)
		#print(0,0,0,ReportNum)	
		return [0,0,0,ReportNum]

	if((sourceNum != 0) & (ReportNum != 0)):
		union = sourceRace.merge(toolReport, how = 'outer' ,indicator=False)
		intersect = sourceRace.merge(toolReport, how = 'inner' ,indicator=False)
		left = sourceRace.merge(toolReport, how = 'outer' ,indicator=True).loc[lambda x : x['_merge']=='left_only']
		right = sourceRace.merge(toolReport, how = 'outer' ,indicator=True).loc[lambda x : x['_merge']=='right_only']
		#print("intersect")
		#print(intersect)
		#print("left")
		#print(left)
		#print("right")
		#print(right)
	return [len(intersect), len(left), 0, len(right)]
	

def checkTN(sourceRace, toolReport):
	if  ('ref1_type' in sourceRace):
		sourceRace.drop(columns=['ref1_type','ref2_type'],inplace=True)
	if  ('ref1_type' in toolReport):
		toolReport.drop(columns=['ref1_type','ref2_type'],inplace=True)
	intersect = sourceRace.columns.intersection(toolReport.columns)
	#print (len(intersect))
	if((len(intersect) != 0)):
		sourceRace = sourceRace[intersect];
	
	sourceRace = sourceRace.drop_duplicates()
	toolReport = toolReport.drop_duplicates()

	sourceNum = len(sourceRace)
	ReportNum = len(toolReport)
	#print(sourceRace)
	#print(toolReport)
	# return Total, Inspector, Ttsan, ROMP
	result = [0]
	if ((sourceNum == 0) & (ReportNum == 0)) :
		result = [0]
	elif ((sourceNum > 0) & (ReportNum == 0)) :
		result = [0]
	elif ((sourceNum == 0) & (ReportNum > 0)) :
		result = [ReportNum]
	elif((sourceNum != 0) & (ReportNum != 0)):
		right = sourceRace.merge(toolReport, how = 'outer' ,indicator=True).loc[lambda x : x['_merge']=='right_only']
		#print("find TN")
		#print(right)
		result = [len(right)]
	return result	
	

def main(argv):
	# micro-bechmarks in C
	SRCDIR = argv[0] 
	INSPECTORDIR = argv[1] 
	TSANDIR = argv[2] 
	ROMPDIR = argv[3] 
	CODEDIR = argv[4] 
	LLOVDIR = argv[5] 

	allReport = pd.DataFrame(columns = ['Name', 'TP_inspect', 'FN_inspect', 'TN_inspect', 'FP_inspect', 'TP_tsan', 'FN_tsan', 'TN_tsan', 'FP_tsan', 'TP_romp', 'FN_romp', 'TN_romp', 'FP_romp', 'TP_code', 'FN_code', 'TN_code', 'FP_code', 'TP_llov', 'FN_llov', 'TN_llov', 'FP_llov', 'totalFP'])

	cfiles = [f for f in os.listdir(SRCDIR) if os.path.isfile(os.path.join(SRCDIR, f))]
	for f in cfiles:
		fullpath = os.path.join(SRCDIR, f)
		srcname = os.path.basename(fullpath)
		srcname = os.path.splitext(srcname)[0]
		#print("processing C:" + srcname)
		sourceRace = getsource(fullpath)
		#print(sourceRace)

		inspectorname = srcname + ".inspector.json"
		inspectorpath = os.path.join(INSPECTORDIR, inspectorname)
		inspectorpath = os.path.abspath(inspectorpath)
		#print("process Inspector report:" + inspectorpath)
		inspectorReport = getTooReport(inspectorpath)
		inspectorReport['tool'] = 'inspector'
		#print(inspectorReport)
		result1 = checkRace(sourceRace, inspectorReport)

		tsanname = srcname + ".tsan-clang.json"
		tsanpath = os.path.join(TSANDIR, tsanname)
		tsanpath = os.path.abspath(tsanpath)
		#print("process Inspector report:" + tsanpath)
		tsanReport = getTooReport(tsanpath)
		tsanReport['tool'] = 'tsan'
		#print(tsanReport)
		result2 = checkRace(sourceRace, tsanReport)

		rompname = srcname + ".romp.json"
		romppath = os.path.join(ROMPDIR, rompname)
		romppath = os.path.abspath(romppath)
		#print("process Inspector report:" + romppath)
		rompReport = getTooReport(romppath)
		rompReport['tool'] = 'romp'
		#print(rompReport)
		result3 = checkRace(sourceRace, rompReport)

		coderrectname = srcname + ".coderrect.json"
		coderrectpath = os.path.join(CODEDIR, coderrectname)
		coderrectpath = os.path.abspath(coderrectpath)
		#print("process Inspector report:" + coderrectpath)
		coderrectReport = getTooReport(coderrectpath)
		coderrectReport['tool'] = 'coderrect'
		#print(coderrectReport)
		result4 = checkRace(sourceRace, coderrectReport)

		llovname = srcname + ".llov.1_comp.json"
		llovpath = os.path.join(LLOVDIR, llovname)
		llovpath = os.path.abspath(llovpath)
		#print("process Inspector report:" + llovpath)
		llovReport = getTooReport(llovpath)
		llovReport['tool'] = 'llov'
		print(llovReport)
		result5 = checkRace(sourceRace, llovReport)

		allreport = pd.concat([inspectorReport,tsanReport,rompReport, coderrectReport, llovReport], axis=0, ignore_index=True)
		#print(allreport)

		TNcount = checkTN(sourceRace, allreport)
		result = list(itertools.chain(result1, result2, result3, result4, result5, TNcount)) 
		result.insert(0,srcname)
		#print(result)
		a_series = pd.Series(result, index = allReport.columns)

		allReport = allReport.append(a_series, ignore_index=True)

		#genRaceInfoJsonFile(fullpath,os.path.join(REF_DIR, "C"))
		#queryandcompare(sys.argv[1:])
	for index, row in allReport.iterrows():
		#print(row['Name'], row['FP_inspect'],row['FP_tsan'],row['FP_romp'],row['totalFP'])
		if(re.match(r".*-yes\..*",row['Name'])):
			row['TN_inspect'] = (int(row['totalFP']) - int(row['FP_inspect']))
			row['TN_tsan'] = (int(row['totalFP']) - int(row['FP_tsan']))
			row['TN_romp'] = (int(row['totalFP']) - int(row['FP_romp']))
			row['TN_code'] = (int(row['totalFP']) - int(row['FP_code']))
			row['TN_llov'] = (int(row['totalFP']) - int(row['FP_llov']))
		#print(row['Name'], row['TN_inspect'],row['TN_tsan'],row['TN_romp'])

	allReport=allReport.append(allReport[['TP_inspect', 'FN_inspect', 'TN_inspect', 'FP_inspect','TP_tsan', 'FN_tsan', 'TN_tsan', 'FP_tsan', 'TP_romp', 'FN_romp', 'TN_romp', 'FP_romp', 'TP_code', 'FN_code', 'TN_code', 'FP_code', 'TP_llov', 'FN_llov', 'TN_llov', 'FP_llov','totalFP']].sum(),ignore_index=True).fillna('')

	allReport.to_csv("Summary.csv", encoding='utf-8', index=False)
	print(allReport.iloc[-1])
	TP_inspect = allReport.iloc[-1]['TP_inspect']
	FN_inspect = allReport.iloc[-1]['FN_inspect']
	TN_inspect = allReport.iloc[-1]['TN_inspect']
	FP_inspect = allReport.iloc[-1]['FP_inspect']
	TP_tsan = allReport.iloc[-1]['TP_tsan']
	FN_tsan = allReport.iloc[-1]['FN_tsan']
	TN_tsan = allReport.iloc[-1]['TN_tsan']
	FP_tsan = allReport.iloc[-1]['FP_tsan']
	TP_romp = allReport.iloc[-1]['TP_romp']
	FN_romp = allReport.iloc[-1]['FN_romp']
	TN_romp = allReport.iloc[-1]['TN_romp']
	FP_romp = allReport.iloc[-1]['FP_romp']
	TP_code = allReport.iloc[-1]['TP_code']
	FN_code = allReport.iloc[-1]['FN_code']
	TN_code = allReport.iloc[-1]['TN_code']
	FP_code = allReport.iloc[-1]['FP_code']
	TP_llov = allReport.iloc[-1]['TP_llov']
	FN_llov = allReport.iloc[-1]['FN_llov']
	TN_llov = allReport.iloc[-1]['TN_llov']
	FP_llov = allReport.iloc[-1]['FP_llov']

	AC_inspect = (TP_inspect + TN_inspect) / (TP_inspect + FN_inspect + TN_inspect + FP_inspect)
	AC_tsan = (TP_tsan + TN_tsan) / (TP_inspect + FN_tsan + TN_tsan + FP_tsan)
	AC_romp = (TP_romp + TN_romp) / (TP_inspect + FN_romp + TN_romp + FP_romp)
	AC_code = (TP_code + TN_code) / (TP_inspect + FN_code + TN_code + FP_code)
	AC_llov = (TP_llov + TN_llov) / (TP_inspect + FN_llov + TN_llov + FP_llov)

	if (TN_inspect+FP_inspect) != 0:
		SP_inspect = (TN_inspect) / (TN_inspect + FP_inspect)
	else:
		SP_inspect = 'N/A'
	if (TN_tsan+FP_tsan) != 0:
		SP_tsan = (TN_tsan) / (TN_tsan + FP_tsan)
	else:
		SP_tsan = 'N/A'
	if (TN_romp+FP_romp) != 0:
		SP_romp = (TN_romp) / (TN_romp + FP_romp)
	else:
		SP_romp = 'N/A'
	if (TN_code+FP_code) != 0:
		SP_code = (TN_code) / (TN_code + FP_code)
	else:
		SP_code = 'N/A'
	if (TN_llov+FP_llov) != 0:
		SP_llov = (TN_llov) / (TN_llov + FP_llov)
	else:
		SP_llov = 'N/A'


	if (TP_inspect+FP_inspect) != 0:
		PR_inspect = (TP_inspect) / (TP_inspect + FP_inspect)
	else:
		PR_inspect = 'N/A'
	if (TP_tsan+FP_tsan) != 0:
		PR_tsan = (TP_tsan) / (TP_tsan + FP_tsan)
	else:
		PR_tsan = 'N/A'
	if (TP_romp+FP_romp) != 0:
		PR_romp = (TP_romp) / (TP_romp + FP_romp)
	else:
		PR_romp = 'N/A'
	if (TP_code+FP_code) != 0:
		PR_code = (TP_code) / (TP_code + FP_code)
	else:
		PR_code = 'N/A'
	if (TP_llov+FP_llov) != 0:
		PR_llov = (TP_llov) / (TP_llov + FP_llov)
	else:
		PR_llov = 'N/A'


	if (TP_inspect+FN_inspect) != 0:
		RE_inspect = (TP_inspect) / (TP_inspect + FN_inspect)
	else:
		RE_inspect = 'N/A'
	if (TP_tsan+FN_tsan) != 0:
		RE_tsan = (TP_tsan) / (TP_tsan + FN_tsan)
	else:
		RE_tsan = 'N/A'
	if (TP_romp+FN_romp) != 0:
		RE_romp = (TP_romp) / (TP_romp + FN_romp)
	else:
		RE_romp = 'N/A'
	if (TP_code+FN_code) != 0:
		RE_code = (TP_code) / (TP_code + FN_code)
	else:
		RE_code = 'N/A'
	if (TP_llov+FN_llov) != 0:
		RE_llov = (TP_llov) / (TP_llov + FN_llov)
	else:
		RE_llov = 'N/A'
	
	if(SP_inspect == 'N/A' or PR_inspect == 'N/A' or RE_inspect == 'N/A'):
		F1_inspect = 'N/A'
	else:
		F1_inspect = 2 * PR_inspect * RE_inspect / (PR_inspect+RE_inspect)
			
	if(SP_tsan == 'N/A' or PR_tsan == 'N/A' or RE_tsan == 'N/A'):
		F1_tsan = 'N/A'
	else:
		F1_tsan = 2 * PR_tsan * RE_tsan / (PR_tsan+RE_tsan)
			
	if(SP_romp == 'N/A' or PR_romp == 'N/A' or RE_romp == 'N/A'):
		F1_romp = 'N/A'
	else:
		F1_romp = 2 * PR_romp * RE_romp / (PR_romp+RE_romp)

	if(SP_code == 'N/A' or PR_code == 'N/A' or RE_code == 'N/A'):
		F1_code = 'N/A'
	else:
		F1_code = 2 * PR_code * RE_code / (PR_code+RE_code)

	if(SP_llov == 'N/A' or PR_llov == 'N/A' or RE_llov == 'N/A'):
		F1_llov = 'N/A'
	else:
		F1_llov = 2 * PR_llov * RE_llov / (PR_llov+RE_llov)

	print("AC_inspect:", AC_inspect)			
	print("PR_inspect:", PR_inspect)			
	print("SP_inspect:", SP_inspect)			
	print("RE_inspect:", RE_inspect)			
	print("F1_inspect:", F1_inspect)			
	
	print("AC_tsan:", AC_tsan)			
	print("PR_tsan:", PR_tsan)			
	print("SP_tsan:", SP_tsan)			
	print("RE_tsan:", RE_tsan)			
	print("F1_tsan:", F1_tsan)			
	
	print("AC_romp:", AC_romp)			
	print("PR_romp:", PR_romp)			
	print("SP_romp:", SP_romp)			
	print("RE_romp:", RE_romp)			
	print("F1_romp:", F1_romp)			
	
	print("AC_code:", AC_code)			
	print("PR_code:", PR_code)			
	print("SP_code:", SP_code)			
	print("RE_code:", RE_code)			
	print("F1_code:", F1_code)			
	
	print("AC_llov:", AC_llov)			
	print("PR_llov:", PR_llov)			
	print("SP_llov:", SP_llov)			
	print("RE_llov:", RE_llov)			
	print("F1_llov:", F1_llov)			
	
if __name__ == "__main__":
	main(sys.argv[1:])

