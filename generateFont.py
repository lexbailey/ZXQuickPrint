#!/usr/bin/env python3

from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw 

import re

font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf", 21)

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
				end = y
				done=True
				break
		if done:
			break
	return start, end

def doChar(thisChar, startLineNum):
	output = ""
	height = font.getsize(thisChar)[1]
	width = 21
	size = (height, width) #This is not the wrong way around, it's going to be rotated
	
	
	charImg = Image.new("1", size)
	charDraw = ImageDraw.Draw(charImg)
	charDraw.text((0,0), thisChar, (255,255,255), font=font)
	charImg = charImg.rotate(-90, expand=True)
	lineNum = startLineNum
	start, end = startAndEndLines(charImg, width, height)
	if thisChar == " ":
		start, end = 0, 10
	for y in range(start, end):
		output += "%d LPRINT \"" % (lineNum)
		lineNum += 1
		for x in range(width):
			pixel = charImg.getpixel((x, y))
			if pixel:
				output += "#"
			else:
				output += " "

		output += "\"\n"
	output += "%d RETURN\n" % (lineNum)
	lineNum +=1
	return (output, lineNum-1)
	
lineNum = 600
print("%d LPRINT CHR$ 13+CHR$ 10" % (lineNum))
lineNum +=1
gosubCallLineNum = lineNum
lineNum +=3
fontBlock = ""
lut = {}
for c in range(32, 127):
	(text, nextLineNum) = doChar(chr(c), lineNum)
	lut[c] = lineNum
	fontBlock += text
	lineNum = nextLineNum+1
lutStart = lineNum
print("%d GO SUB %d" % (gosubCallLineNum, lutStart))
print("%d LPRINT CHR$ 13+CHR$ 10" % (gosubCallLineNum+1))
print("%d RETURN" % (gosubCallLineNum+2))
print(fontBlock, end='')
for key, value in lut.items():
	print("%d IF a$=CHR$ %d THEN GO TO %d" % (lineNum, key, value))
	lineNum += 1
print("%d RETURN" % (lineNum))
lineNum += 1
