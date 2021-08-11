import json
import re
import sys

def main(argv):
	matchpattern = re.compile(r'.+\/(DRB[a-zA-Z0-9\.\-]+):(\d+):?(\d+)?')
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("Data Race detected",content[i])
		if (x):
			y = re.search("File :",content[i+1])
			if (y):
				r = matchpattern.search(content[i+1])
				#print(len(r.groups()))
				#print(r.groups())
				#print(r.group(1))
				#print(r.group(2))
				#print(r.group(3))
				js = {}
				js["ref1_filename"] = r.group(1)
				js["ref1_line"] = r.group(2)
				#if len(r.groups()) == 3:
				#	js["ref1_column"] = r.group(3)
				js["ref2_filename"] = r.group(1)
				js["ref2_line"] = r.group(2)
				#if len(r.groups()) == 3:
				#	js["ref2_column"] = r.group(3)
				jsAry.append(js)
			y = re.search("Source :",content[i+1])
			if (y):
				y2 = re.search("Sink :",content[i+2])
				if (y2):
					r1 = matchpattern.search(content[i+1])
					r2 = matchpattern.search(content[i+2])
					#print(r1.group(1))
					#print(r1.group(2))
					#print(r2.group(1))
					#print(r2.group(2))
					js = {}
					js["ref1_filename"] = r1.group(1)
					js["ref1_line"] = r1.group(2)
					#if len(r1.groups()) == 3:
					#	js["ref1_column"] = r1.group(3)
					js["ref2_filename"] = r2.group(1)
					js["ref2_line"] = r2.group(2)
					#if len(r2.groups()) == 3:
					#	js["ref2_column"] = r2.group(3)
					jsAry.append(js)
	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

