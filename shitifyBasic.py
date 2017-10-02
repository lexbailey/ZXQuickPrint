#!/usr/bin/env python

"""
    shitifyBasic.py Takes some non-shit 
    BASIC and turns it into shit BASIC.
"""

import sys
import re
import argparse
from math import floor

parser = argparse.ArgumentParser(description='Shitfy BASIC-like code')
parser.add_argument('file', type=str)
parser.add_argument('--debug', action="store_true")
args = parser.parse_args()

filename = args.file
outfilename = filename + ".shit"

debug = args.debug

linenum = 0

outbuffer = []

labels = []

fixups = []

thisasm = []

curasm = None

asms = {}

def asm(asm, name):
    bareasm = []
    for line in asm:
        if '#' in line:
            line = line[0:line.index('#')]
        line = line.strip()
        bareasm.append(line)
    string = "".join(bareasm)
    if len(string)%2 != 0:
        print("ASM '%s' is not the right length" % name, file=sys.stderr)
        sys.exit(1)

    asms[name] = [int(string[i*2:(i*2)+2], 16) for i in range(floor(len(string)/2))]

with open(filename) as infile:
    while True:
        line = infile.readline()
        if not line:
            break
        m = re.match(r"^ASMDATASTART (.*)$", line)
        if m:
            curasm = m.groups()[0].strip()
        else:
            m = re.match("^ASMDATAEND$", line)
            if m:
                asm(thisasm, curasm)
                curasm = None
                thisasm = []
            elif curasm is not None:
                thisasm.append(line)


linegroup = []
def flush():
    global outbuffer, linegroup
    if linegroup == []:
        return
    assert not None in linegroup
    outbuffer.append("%s\n" % (':'.join(line.strip() for line in linegroup)))
    linegroup = []

inasm = False
with open(filename) as infile:
    while True:
        line = infile.readline()
        if line:
            if not inasm:
                inasm = re.match(r"^ASMDATASTART (.*)$", line)
            if inasm:
                inasm = not re.match("^ASMDATAEND$", line)
                continue
            m = re.match(r"^LOADASMDATA +([0-9]+) +(.+)$", line)
            if m:
                dest, name = m.groups()
                dest = int(dest)
                name = name.strip()
                limit = dest + len(asms[name])-1
                flush()
                outbuffer.append("RESTORE %d\n" % (len(outbuffer)+1))
                outbuffer.append("DATA %s\n" % (','.join(str(asm) for asm in asms[name])))
                outbuffer.append("FOR c=%d TO %d\n" % (dest, limit))
                outbuffer.append("READ n: POKE c,n\n")
                outbuffer.append("NEXT c\n")
                continue
            m = re.match(r"^LABEL:(.*)$", line)
            if not m:
                m = re.match(r"^(.*)GO (SUB|TO) (.*)$", line)
                if m:
                    prefix, action, destlabel = m.groups()
                    if destlabel.startswith("RAWLINE:"):
                        destline = destlabel[8:]
                        flush()
                        outbuffer.append("%sGO %s %s\n" % (prefix, action, destline))
                    else:
                        flush()
                        fixups.append((len(outbuffer), prefix, action, destlabel))
                        outbuffer.append(None)
                else:
                    if not any([
                            line.strip() == "",
                            line.startswith("REM")
                        ]):
                        if "REM" in line:
                            flush()
                            outbuffer.append(line)
                        else:
                            linegroup.append(line)
                            if debug:
                                flush()
            else:
                flush()
                labels.append((len(outbuffer), m.groups()[0].strip()))
        else:
            break
    flush()


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
