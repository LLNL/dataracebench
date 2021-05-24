import json
import re
import sys

def main(argv):
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("Write",content[i])
		if (x):
			y = content[i].split()
			js = {}
			if(re.search("^/",y[0])):
				file = y[0].rsplit("/",1)
				location = file[1].split(":")
				f = location[0].split("(")
				js["ref1_filename"] = f[0]
				line = f[1].split(")")
				js["ref1_line"] = line[0]
				js["ref1_type"] = 'W'
			x = re.search("Read",content[i+1])
			if (x):
				y = content[i+1].split()
				if(re.search("^/",y[0])):
					file = y[0].rsplit("/",1)
					location = file[1].split(":")
					f = location[0].split("(")
					js["ref2_filename"] = f[0]
					line = f[1].split(")")
					js["ref2_line"] = line[0]
					js["ref2_type"] = 'R'
				# js["tool"] = "intel-instpector"
				jsAry.append(js)
		x = re.search("Read",content[i])
		if (x):
			y = content[i].split()
			js = {}
			if(re.search("^/",y[0])):
				file = y[0].rsplit("/",1)
				location = file[1].split(":")
				f = location[0].split("(")
				js["ref1_filename"] = f[0]
				line = f[1].split(")")
				js["ref1_line"] = line[0]
				js["ref1_type"] = 'R'
			x = re.search("Write",content[i+1])
			if (x):
				y = content[i+1].split()
				if(re.search("^/",y[0])):
					file = y[0].rsplit("/",1)
					location = file[1].split(":")
					f = location[0].split("(")
					js["ref2_filename"] = f[0]
					line = f[1].split(")")
					js["ref2_line"] = line[0]
					js["ref2_type"] = 'W'
				# js["tool"] = "intel-instpector"
				jsAry.append(js)
	
	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	
	r = json.dumps(js)
	print(r)

if __name__ == "__main__":
	main(sys.argv[1:])

