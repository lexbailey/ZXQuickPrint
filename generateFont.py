#!/usr/bin/env python

import sys
import os

from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw 

import re
import math
import textwrap
import argparse

parser = argparse.ArgumentParser(description='Font generator.')
parser.add_argument('fontfile', help='Path to font')
parser.add_argument('-o', help='Output file name')
args = parser.parse_args()
outname=args.o
print(args.fontfile, file=sys.stderr)

#font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf", 21)
font = ImageFont.truetype(args.fontfile, 21)
name = os.path.splitext(os.path.basename(args.fontfile))[0]
if len(name) > 10:
	name = name[0:10]
print(name, file=sys.stderr)

init_start = 600

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
		if line == curline and run_length < 4:
			run_length += 1
		else:
			outlines.append(curline + encode_length(run_length, False))
			run_length = 1
			curline = line
	outlines.append(curline + encode_length(run_length, True))
	return outlines

def doChar(thisChar, offset):
	output = ""
	height = font.getsize(thisChar)[1]
	width = 21
	size = (height, width) #This is not the wrong way around, it's going to be rotated
	
	charImg = Image.new("1", size)
	charDraw = ImageDraw.Draw(charImg)
	charDraw.text((0, offset), thisChar, "white", font=font)
	charImg = charImg.rotate(-90, expand=True)
	start, end = startAndEndLines(charImg, width, height)
	if thisChar == " ":
		start, end = 0, 10
	lines = []
	for y in range(start, end):
		lines.append("".join("1" if charImg.getpixel((x, y)) else "0" for x in range(width)))
	if lines == []:
		lines = ["000000000000000000000",
				 "000000000000000000000",
				 "000000000000000000000",
				 "000000000010000000000",
				 "000000000000000000000",
				 "000000000000000000000",
				 "000000000000000000000",
				 "000000000000000000000"
				 ]
	lines = runlength_encode(lines)
	lines = [int(line, 2) for line in lines]
	
	return lines

def chunks(l, n):
	"""Yield successive n-sized chunks from l."""
	for i in range(0, len(l), n):
		yield l[i:i + n]

def find_offset():
	offset = 0
	add = False
	sub = False
	while True:
		allnums = []
		for c in range(32,127):
			numbers = doChar(chr(c), offset)
			allnums.extend(numbers)
		if all((number & (2**(20+3)))==0 for number in allnums):
			offset += 1
			add = True
		elif all((number & (2**(0+3)))==0 for number in allnums):
			offset -= 1
			sub = True
		else:
			break
		if add and sub:
			break
	return offset

# Character printing function
fontdata = []
lut = {}
index = 0
offset = find_offset()
for c in range(32, 127):
	numbers = doChar(chr(c), offset)
	lut[c] = index
	index += len(numbers)
	fontdata += numbers

def charindex_block(charindex):
	block = []
	for i in charindex:
		block.append(i & 0xff)
		block.append(i>>8)
	return bytes(block)

charindex = [lut[c]*3 for c in range(32, 127)]

def int_to_bytes(number):
	b1 = number & 0xff
	b2 = (number >> 8) & 0xff
	b3 = (number >> 16) & 0xff
	return bytes([b3,b2,b1])

total_bytes = 0
if not outname:
	outname = name+"_altfont.dat"
with open(outname, "wb+") as fontfile:
	total_bytes += fontfile.write(charindex_block(charindex))
	for value in fontdata:
		total_bytes += fontfile.write(int_to_bytes(value))

print("Font file size: %d bytes" % (total_bytes), file=sys.stderr)

# vim: set tabstop=4 noexpandtab:
