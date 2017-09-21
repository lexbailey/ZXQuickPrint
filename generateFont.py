#!/usr/bin/env python

import sys

from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw 

import re
import math
import textwrap

font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf", 21)

init_start = 600
printchar_start = 700

def startAndEndLines(charImg, width, height):
	start=0
	end=0
	done=False
	for y in range(height):
		for x in range(width):
			pixel = charImg.getpixel((x, y))
			if pixel:
				start = y
				done=True
				break
		if done:
			break
	done=False
	for y in reversed(range(height)):
		for x in range(width):
			pixel = charImg.getpixel((x, y))
			if pixel:
				end = y+1
				done=True
				break
		if done:
			break
	return start, end

def encode_length(length, islast):
	assert length in [1,2,3,4]
	num = bin(length-1)[2:]
	if len(num) == 1:
		num = "0"+num
	num = ("1" if islast else "0") + num
	return num

def runlength_encode(lines):
	curline = lines[0]
	run_length = 0
	outlines = []
	for i, line in enumerate(lines):
		islast = i == len(lines) -1 
		if line == curline and run_length < 4:
			run_length += 1
		else:
			outlines.append(curline + encode_length(run_length, islast))
			run_length = 1
			curline = line
		if islast:
			outlines.append(curline + encode_length(run_length, islast))
	return outlines

def doChar(thisChar):
	output = ""
	height = font.getsize(thisChar)[1]
	width = 21
	size = (height, width) #This is not the wrong way around, it's going to be rotated
	
	charImg = Image.new("1", size)
	charDraw = ImageDraw.Draw(charImg)
	charDraw.text((0,0), thisChar, "white", font=font)
	charImg = charImg.rotate(-90, expand=True)
	start, end = startAndEndLines(charImg, width, height)
	if thisChar == " ":
		start, end = 0, 10
	lines = []
	for y in range(start, end):
		lines.append("".join("1" if charImg.getpixel((x, y)) else "0" for x in range(width)))
	lines = runlength_encode(lines)
	lines = [int(line, 2) for line in lines]
	
	return lines

def chunks(l, n):
	"""Yield successive n-sized chunks from l."""
	for i in range(0, len(l), n):
		yield l[i:i + n]

# Initialisation code
lineNum = init_start
print("%d DIM e(95)" % (lineNum))
lineNum+=1
print("%d RESTORE" % (lineNum))
lineNum+=1
print("%d FOR n=1 TO 95: READ e(n): NEXT n" % (lineNum))
lineNum+=1

# Character printing function
fontdata = []
lut = {}
index = 0
for c in range(32, 127):
	numbers = doChar(chr(c))
	lut[c] = index
	index += len(numbers)
	fontdata += numbers
#fontstrings = [",".join(hex(num)[2:]+'h' for num in fontslice) for fontslice in chunks(fontdata, 20)]
fontstrings = [",".join(str(num) for num in fontslice) for fontslice in chunks(fontdata, 20)]

# Load `index` numbers into f
print("%d DIM f(%d)" % (lineNum, index))
lineNum+=1
print("%d RESTORE" % (lineNum))
lineNum+=1
print("%d FOR n=1 TO %d: READ f(n): NEXT n" % (lineNum, index))
lineNum+=1

assert lineNum <= printchar_start

lineNum = printchar_start
print("%d LPRINT CHR$ 13+CHR$ 10" % (lineNum))
lineNum +=1
print("%d LET i=CODE a$-31" % (lineNum))
lineNum +=1
print("%d LET j=e(i)" % (lineNum)) # Get the index of the character start
lineNum +=1
lineloop_linenum = lineNum
print("%d LET b=f(j)" % (lineNum)) # Get the character start number
lineNum +=1
print("%d LPRINT CHR$ 13+CHR$ 10" % (lineNum))
lineNum +=1
print("%d RETURN" % (lineNum))
lineNum +=1
print("%d DATA %s" % (lineNum, ','.join([str(lut[c]) for c in range(32, 127)])))
lineNum +=1
for fontstring in fontstrings:
	print("%d DATA %s" % (lineNum, fontstring))
	lineNum += 1

# vim: set tabstop=4 noexpandtab:
