import sys, getopt
import ArchoutputParser
import InspectoroutputParser
import CoderrectoutputParser
import RompoutputParser
import LLOVoutputParser
import argparse



def main(argv):
	parser = argparse.ArgumentParser(description='Parse tool Logs')
	parser.add_argument('logfile', metavar='file', type=open, nargs=1,  help='log filename')
	parser.add_argument('--tool', metavar='t', type=ascii, required=True, dest="tool", help='tool option')
	args = parser.parse_args(argv)
	# print(args.logfile[0].name)

	if args.tool == ascii('archer'):
		# print("processing Archer log")
		ArchoutputParser.main([args.logfile[0].name])
	elif args.tool == ascii('tsan'):
		# print("processing Tsan log")
		ArchoutputParser.main([args.logfile[0].name])
	elif args.tool == ascii('inspector'):
		# print("processing Inspector log")
		InspectoroutputParser.main([args.logfile[0].name])
	elif args.tool == ascii('romp'):
		# print("processing Inspector log")
		RompoutputParser.main([args.logfile[0].name])
	elif args.tool == ascii('coderrect'):
		# print("processing Coderrect log")
		CoderrectoutputParser.main([args.logfile[0].name])
	elif args.tool == ascii('llov'):
		# print("processing LLOV log")
		LLOVoutputParser.main([args.logfile[0].name])

#    try:
#        opts, args = getopt.getopt(sys.argv[1:], "ht:v", ["help", "tool="])
#    except getopt.GetoptError as err:
#        # print help information and exit:
#        print(err)  # will print something like "option -a not recognized"
#        usage()
#        sys.exit(2)
#    tool = None
#    verbose = False
#    for o, a in opts:
#        if o == "-v":
#            verbose = True
#        elif o in ("-h", "--help"):
#            usage()
#            sys.exit()
#        elif o in ("-t", "--tool"):
#            tool = a
#            print(tool, " is chosen")	
#        else:
#            assert False, "unhandled option"
#
#    if tool ==  'Archer': 
#        ArchoutputParser.main(sys.argv[3:])
#    elif tool == 'Tsan': 
#        ArchoutputParser.main(sys.argv[3:])

if __name__ == '__main__':
	main(sys.argv[1:])
