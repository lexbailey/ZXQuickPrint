#!/usr/bin/env python

def tobin(val):
    strval = bin(val)[2:]
    strval = "".join(["0"] * (8-len(strval))) + strval
    return strval

def tohashes(string):
    return "".join('#' if c == '1' else ' ' for c in string)

with open("fontdata.dat", "rb") as f:
    data = f.read()
    i = 0
    while i+2< len(data):
        a,b,c = data[i], data[i+1], data[i+2]
        bindata = "".join(tobin(byte) for byte in [a,b,c])
        image, end, rle = bindata[0:21], bindata[21], int(bindata[22:], 2)+1
        for _ in range(rle):
            print("|" + tohashes(image) + "|")
        if end == '1':
            print()
        i+=3
