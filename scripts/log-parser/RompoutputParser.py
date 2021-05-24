import json
import re
import sys

def main(argv):
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("RAW",content[i])
		if (x):
			y = content[i].split()
			index = y.index('addr:')
			js = {}
			js["memAddr"] = y[index+1]
			y = content[i+1].split()
			for i in range(len(y)):
				file = y[0].rsplit("/",1)
				# js["file loaction"] = file[0]
				location = file[1].split(":")
				filename=location[0].split('@')
				js["ref1_filename"] = filename[0]
				js["ref1_line"] = location[1]
				js["ref1_type"] = "W"
				js["ref1_symbolPos"] = y[1]
				file = y[3].rsplit("/",1)
				# js["file loaction"] = file[0]
				location = file[1].split(":")
				js["ref2_filename"] = filename[0]
				js["ref2_line"] = location[1]
				js["ref1_type"] = "R"
				js["ref2_symbolPos"] = y[4]
				# js["tool"] = "romp"
			jsAry.append(js)
	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

