import sys, json

if len(sys.argv) == 4:
    print json.loads(sys.argv[1])[0][sys.argv[2]][sys.argv[3]]
elif len(sys.argv) == 5:
    try:
        print json.loads(sys.argv[1])[0][sys.argv[2]][sys.argv[3]][sys.argv[4]]
    except:
        print 0
elif len(sys.argv) == 6:
    print json.loads(sys.argv[1])[0][sys.argv[2]][sys.argv[3]][0][sys.argv[4]][sys.argv[5]]
