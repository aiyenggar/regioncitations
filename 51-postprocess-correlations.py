#!/usr/bin/env python3
import sys
myargs = sys.argv[1:]
pattern1="\multicolumn{1}{c}{Variables} &"
pattern2="\\\\"
pattern3="\\hline"



for inputfile in myargs:
    print("Processing " + inputfile)
    varstring = None
    with open(inputfile, 'r') as file :
        for line in file:
            if line.startswith(pattern1):
                varstring = line.replace(pattern1,"").replace(pattern2,"").replace(pattern3,"").strip()
                break
    file.close()
    if not varstring:
        print("Nothing to do in " + inputfile)
        continue
    var=varstring.split("&")
    index = 0
    varmap = {}
    already_processed = False
    for pat in var:
        if pat.isdigit():
            already_processed = True
            break
        index += 1
        varmap[pat] = index
    if already_processed:
        print("Cannot process " + inputfile)
        continue
    # Read in the file
    with open(inputfile, 'r') as file :
        filedata = file.read()
        file.close()

    var.sort(key=lambda item: (-len(item), item))

    for pat in var:
        index = varmap[pat]
        # Replace the target string
        filedata = filedata.replace("&"+pat, "&"+str(index))
        filedata = filedata.replace(pat+"&", str(index) + ". " + pat + "&")

    # Write the file out again
    with open(inputfile, 'w') as file:
      file.write(filedata)
    file.close()
