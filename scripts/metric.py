import sys
import csv

data=[]
with open(sys.argv[1],'r') as csvfile:
	content = csv.reader(csvfile, delimiter=',')
	for line in content:
		data.append(line)

benchmarks={}
for line in data[1:]:
	benchmarks.setdefault(line[1],[]).append({"truth":line[3], "races":int(line[6]), "compiler":line[9], "runtime":line[10]})

truePositive = 0
falsePositive = 0
trueNegative = 0
falseNegative = 0
compilertrue = 0
compilererror = 0
compilertimeout = 0
runtimeerror = 0
runtimetrue = 0
runtimeout = 0
runtimeoutreport = 0
positive = 0
negative = 0

Nbenchmarks={}

for app,runs in benchmarks.items():
	Nbenchmarks[app]=runs[0]
	for run in runs[1:]:
		if Nbenchmarks[app]["races"]<run["races"]:
			Nbenchmarks[app]["races"]=run["races"]
		
def classify(truth, races):
	global positive, negative, falseNegative, truePositive, trueNegative, falsePositive
	if truth.upper() == 'TRUE':
		positive += 1 
		if races == 0:
			falseNegative += 1
		else:
			truePositive += 1
	else:
		negative += 1 
		if races == 0:
			trueNegative += 1
		else:
			falsePositive += 1
	
		
for app,run in Nbenchmarks.items():
	if run["compiler"] == '0':
		compilertrue += 1
		if run["runtime"] == '0':
			classify(run["truth"], run["races"])
			runtimetrue += 1
		elif run["runtime"] == '11':
			runtimeerror += 1
		elif run["runtime"] == '124':
			if (run["races"]>0):
				classify(run["truth"], run["races"])
				runtimeoutreport += 1
			else:
				runtimeout += 1
		else:
			print(app, run["runtime"], "there are some errors in your runtime data.")
	elif run["compiler"] in ('1', '2', '4', '134', '254'):
		compilererror += 1
	elif run["compiler"] == '11':
		compilertimeout += 1
	else:
		print(app, run["compiler"], "there are some errors in your compiler data.")

print("total test case is ", len(Nbenchmarks))
print("compiler segmentation fault is ", compilererror)
print("runtime segmentation fault is ", runtimeerror)
print("compiler time out is ", compilertimeout)
print("runtime time out is ", runtimeout)
print("runtime time out with report is ", runtimeoutreport)
print("test support rate is ", (negative+positive)/(len(Nbenchmarks)))
print("false positive is ", falsePositive)
print("true positive is ", truePositive)
print("true negative is ", trueNegative)
print("false negative is ", falseNegative)
Accuracy = (truePositive + trueNegative) / (negative+positive)
if (trueNegative+falsePositive) != 0:
	Specificity = (trueNegative)/(trueNegative+falsePositive)
else:
	Specificity = 'N/A'
if (truePositive + falsePositive) != 0:
	Precision = truePositive / (truePositive + falsePositive)
else:
	Precision = 'N/A'
if (truePositive + falseNegative) != 0:
	Recall = truePositive / (truePositive + falseNegative)
else:
	Recall = 'N/A'
if Specificity == 'N/A' or Precision == 'N/A' or Recall == 'N/A':
	f1Score = 'N/A'
else:
	f1Score = 2 * Precision * Recall / (Precision + Recall)
print("Accuracy is ", Accuracy)
print("Precision is", Precision)
print("Specificity is ", Specificity)
print("Recall is ", Recall)
print("F1 Score is ", f1Score)
