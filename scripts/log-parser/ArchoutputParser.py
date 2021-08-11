import json
import re
import sys

def main(argv):
	file = open(argv[0],"r")
	Lines = file.readlines()
	jsAry = []
	content = [line.strip() for line in Lines]
	for i in range(0,len(content)):
		x = re.search("^Write",content[i])
		if (x):
			y = content[i].split()
			index = y.index('at')
			js = {}
			js["memAddr"] = y[index+1]
			index1 = y.index('by')
			Thread = re.split(":",y[index1+2])
			js["ref1_thread"] = y[index1+1] + ' ' + Thread[0]
			y1 = content[i+1].split()
			for item in y1:
				if(re.search("^/",item)):
					file = item.rsplit("/",1)
					# js["ref1_fileLoc"] = file[0]
					location = file[1].split(":")
					js["ref1_filename"] = location[0]
					js["ref1_type"] = 'W'
					js["ref1_line"] = location[1]
					if len(location) >= 3:
						js["ref1_column"] = location[2]
					else:
						js["ref1_column"] = -1
			jsAry.append(js)
		x = re.search("^Previous read",content[i])
		if (x):
			y = content[i].split()
			index = y.index('at')
			for item in reversed(jsAry):
				if (item["memAddr"] == y[index+1]):
					index1 = y.index('by')
					Thread = re.split(":",y[index1+2])
					item["ref2_thread"] = y[index1+1] + ' ' + Thread[0]
					y1 = content[i+1].split()
					for item1 in y1:
						if(re.search("^/",item1)):
							file = item1.rsplit("/",1)
							location = file[1].split(":")
							item["ref2_filename"] = location[0]
							item["ref2_type"] = 'R'
							item["ref2_line"] = location[1]
							if len(location) >= 3:
								js["ref2_column"] = location[2]
							else:
								js["ref2_column"] = -1
							#item["tool"] = "Archer"
					break
		atomicRead = False	
		x = re.search("^Read",content[i])
		if not x:
			x = re.search("^Atomic read",content[i])
			if (x):
				atomicRead = True	
		if (x):
			y = content[i].split()
			index = y.index('at')
			js = {}
			js["memAddr"] = y[index+1]
			index1 = y.index('by')
			Thread = re.split(":",y[index1+2])
			js["ref1_thread"] = y[index1+1] + ' ' + Thread[0]
			y1 = content[i+1].split()
			for item in y1:
				if(re.search("^/",item)):
					file = item.rsplit("/",1)
					# js["ref1_fileLoc"] = file[0]
					location = file[1].split(":")
					js["ref1_filename"] = location[0]
					js["ref1_type"] = "R"
					js["ref1_line"] = location[1]
					if len(location) >= 3:
						js["ref1_column"] = location[2]
					else:
						js["ref1_column"] = -1
			jsAry.append(js)
		atomicWrite = False	
		x = re.search("^Previous write",content[i])
		if not x:
			x = re.search("^Previous atomic write",content[i])
			if (x):
				atomicWrite = True	
		if (x):
			y = content[i].split()
			index = y.index('at')
			for item in reversed(jsAry):
				if (item["memAddr"] == y[index+1]):
					index1 = y.index('by')
					Thread = re.split(":",y[index1+2])
					item["ref2_thread"] = y[index1+1] + ' ' + Thread[0]
					y1 = content[i+1].split()
					if(atomicWrite):
						y1 = content[i+2].split()
					for item1 in y1:
						if(re.search("^/",item1)):
							file = item1.rsplit("/",1)
							location = file[1].split(":")
							item["ref2_filename"] = location[0]
							item["ref2_type"] = 'W'
							item["ref2_line"] = location[1]
							if len(location) >= 3:
								js["ref2_column"] = location[2]
							else:
								js["ref2_column"] = -1
							# item["tool"] = "Archer"
					break
	
	
	js = {}
	for i in range(len(jsAry)):
		js[i] = jsAry[i]
	
	r = json.dumps(js)
	print(r)


if __name__ == "__main__":
	main(sys.argv[1:])

