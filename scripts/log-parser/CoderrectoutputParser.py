import json
import re
import sys

def main(argv):
	matchpattern = re.compile(r'line (\d+), column (\d+) in .+\/(DRB\S+).+line (\d+), column (\d+) in .+\/(DRB\S+)')
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("Found a data race between",content[i])
		if (x):
			#print(content[i+1])
			y = matchpattern.search(content[i+1])
			#print(y.group(1))
			#print(y.group(2))
			#print(y.group(3))
			#print(y.group(4))
			#print(y.group(5))
			#print(y.group(6))
			js = {}
			js["ref1_filename"] = y.group(3)
			js["ref1_line"] = y.group(1)
			js["ref1_column"] = y.group(2)
			js["ref2_filename"] = y.group(6)
			js["ref2_line"] = y.group(4)
			js["ref2_column"] = y.group(5)
			jsAry.append(js)

	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

