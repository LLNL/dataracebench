import sys
import csv

file = open(sys.argv[1],"r")
lines = file.readlines()
content = [line.strip() for line in lines]
truth = []
races = []
compiler = []
runtime = []
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
	if len(num) > 10:
		truth.append(num[3])
		races.append(num[6])
		compiler.append(num[9])
		runtime.append(num[10])
	elif len(num) > 3:
		truth.append(num[3])
		races.append(num[6])
	else:
		compiler.append(num[1])
		runtime.append(num[2])        
for i in range(1,len(truth)):
	if truth[i] == 'true':
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
	if compiler[i] == '0':
		compilertrue += 1
	elif compiler[i] == '1':
		compilererror += 1
        elif compiler[i] == '11':
                compilertimeout += 1
	else:
		print("there are some errors in your data.")
	if runtime[i] == '0':
		runtimetrue += 1
	elif runtime[i] == '1':
		runtimeerror += 1
        elif runtime[i] == '11':
                runtimeout += 1
	else:
		print("there are some errors in your data.")
print("total test case is ", len(compiler)-1)
print("compiler segmentation fault is ", compilererror)
print("runtime segmentation fault is ", runtimeerror)
print("compiler time out is ", compilertimeout)
print("runtime time out is ", runtimeout)
print("tools fail rate is ", compilertrue/(compilertrue+ compilererror+compilertimeout))
print("false positive is ", falsePositive)
print("true positive is ", truePositive)
print("true negative is ", trueNegative)
print("false negative is ", falseNegative)
Accuracy = (truePositive + trueNegative) / (len(truth)-1)
Specificity = (trueNegative)/(trueNegative+falsePositive)
Precision = truePositive / (truePositive + falsePositive)
Recall = truePositive / (truePositive + falseNegative)
f1Score = 2 * Precision * Recall / (Precision + Recall)
print("Accuracy is ", Accuracy)
print("Precision is", Precision)
print("Specificity is ", Specificity)
print("Recall is ", Recall)
print("F1 Score is ", f1Score)

