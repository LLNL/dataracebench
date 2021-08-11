import json
import re
import sys

def main(argv):
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("RAW: data race",content[i])
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
				#js["ref1_type"] = "N/A"
				js["ref1_column"] = y[1].split(":")[1]
				file = y[3].rsplit("/",1)
				# js["file loaction"] = file[0]
				location = file[1].split(":")
				js["ref2_filename"] = filename[0]
				js["ref2_line"] = location[1]
				#js["ref2_type"] = "N/A"
				js["ref2_column"] = y[4].split(":")[1]
				# js["tool"] = "romp"
			jsAry.append(js)
	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

