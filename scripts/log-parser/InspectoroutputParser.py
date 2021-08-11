import json
import re
import sys

def main(argv):
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("P\d+\.\d+: Error: Data race",content[i])
		if (x):
			y1 = content[i+1].split()
			if "Allocation site:" in content[i+1]:
				y1 = content[i+3].split()
			js = {}
			if(re.search("^/",y1[0])):
				file1 = y1[0].rsplit("/",1)
				location = file1[1].split(":")
				f1 = location[0].split("(")
				js["ref1_filename"] = f1[0]
				if(y1[3] == "Read:"):
					js["ref1_type"] = "R"
				else:
					js["ref1_type"] = "W"
				line = f1[1].split(")")
				js["ref1_line"] = line[0]

			y2 = content[i+2].split()
			if(re.search("^/",y2[0])):
				file2 = y2[0].rsplit("/",1)
				location = file2[1].split(":")
				f2 = location[0].split("(")
				js["ref2_filename"] = f2[0]
				if(y2[3] == "Read:"):
					js["ref2_type"] = "R"
				else:
					js["ref2_type"] = "W"
				line = f2[1].split(")")
				js["ref2_line"] = line[0]
			jsAry.append(js)

	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

