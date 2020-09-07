import sys
import csv

file = open(sys.argv[1],"r")
lines = file.readlines()
content = [line.strip() for line in lines]
truth = []
races = []
compiler = []
runtime = []
id = []
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
positive = 0
negative = 0
for item in content:
	num = item.split(",")
	while("" in num):
		num.remove("")
	if len(num) > 10:
		truth.append(num[3])
		races.append(num[6])
		id.append(num[1])
		compiler.append(num[9])
		runtime.append(num[10])
	elif len(num) == 10:
		truth.append(num[3])
		races.append(num[6])
		id.append(num[1])
		compiler.append(num[8])
		runtime.append(num[9])
	elif len(num) == 7:
		truth.append(num[3])
		races.append("")
		id.append(num[1])
		compiler.append(num[6])
		runtime.append("")
	elif len(num) > 3:
		id.append(num[1])
		truth.append(num[3])
		races.append(num[6])
	else:
		compiler.append(num[1])
		runtime.append(num[2])
Nid = []
Ntruth = []
Ncompiler = []
Nruntime = []
Nraces = []
for i in range(1,len(truth)):
	if id[i] in Nid:
		if races[i] != Nraces[-1] and races[i] != '0':
			Nraces.pop()
			Nraces.append(races[i])
	else:
		Nid.append(id[i])
		Ntruth.append(truth[i])
		Ncompiler.append(compiler[i])
		Nruntime.append(runtime[i]) 
		Nraces.append(races[i])
id = Nid
truth = Ntruth
compiler = Ncompiler
runtime = Nruntime
races = Nraces
for i in range(len(Ntruth)):
	if compiler[i] == '0':
		compilertrue += 1
		if runtime[i] == '0':
			runtimetrue += 1
			if truth[i].upper() == 'TRUE':
				positive += 1 
				if races[i] == '0':
					falseNegative += 1
				else:
					truePositive += 1
			else:
				negative += 1 
				if races[i] == '0':
					trueNegative += 1
				else:
					falsePositive += 1
		elif runtime[i] == '11':
			runtimeerror += 1
		elif runtime[i] == '124':
			runtimeout += 1
		else:
			print(runtime[i])
			print(id[i])
			print("there are some errors in your runtime data.")
	elif compiler[i] == '1' or compiler[i] == '2' or compiler[i] == '4' or compiler[i] == '134' or compiler[i] == '254':
		compilererror += 1
	elif compiler[i] == '11':
		compilertimeout += 1
	else:
		print(compiler[i])
		print(id[i])
		print("there are some errors in your compiler data.")
print("total test case is ", len(id))
print("compiler segmentation fault is ", compilererror)
print("runtime segmentation fault is ", runtimeerror)
print("compiler time out is ", compilertimeout)
print("runtime time out is ", runtimeout)
print("tool success rate is ", (negative+positive)/(len(id)))
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
