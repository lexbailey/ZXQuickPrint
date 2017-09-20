#!/usr/bin/env python

"""
    shitifyBasic.py Takes some non-shit 
    BASIC and turns it into shit BASIC.
"""

import sys
import re
import argparse

parser = argparse.ArgumentParser(description='Shitfy BASIC-like code')
parser.add_argument('file', type=str)
args = parser.parse_args()

filename = args.file
outfilename = filename + ".shit"

linenum = 0

outbuffer = []

labels = []

fixups = []

with open(filename) as infile:
    while True:
        line = infile.readline()
        if line:
            m = re.match(r"^LABEL:(.*)$", line)
            if not m:
                m = re.match(r"^(.*)GO (SUB|TO) (.*)$", line)
                if m:
                    print(m.groups())
                    prefix, action, destlabel = m.groups()
                    if destlabel.startswith("RAWLINE:"):
                        destline = destlabel[8:]
                        outbuffer.append("%sGO %s %s\n" % (prefix, action, destline))
                    else:
                        fixups.append((len(outbuffer), prefix, action, destlabel))
                        outbuffer.append(None)
                else:
                    outbuffer.append(line)
            else:
                labels.append((len(outbuffer), m.groups()[0].strip()))
        else:
            break


def label_to_num(targetlabel):
    for num, label in labels:
        if label == targetlabel:
            return num + 1
    raise ValueError()

last_fixup = 0
for i, prefix, action, label in fixups:
    try:
        destline = label_to_num(label)
    except ValueError:
        print("No such label: %s" % (label), file=sys.stderr)
        sys.exit(1)
    outbuffer[i] = "%sGO %s %s\n" % (prefix, action, destline)

with open(outfilename, 'w+') as outfile:
    for i, line in enumerate(outbuffer):
        print("%d %s" % (i+1, line), end="", file=outfile)
