#!/usr/bin/env python3

from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw 

import re
import math
import textwrap

font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf", 21)

lineNum = 600

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
	
def lutToBST(lut):
	if len(lut) == 0:
		return None
	if len(lut) == 1:
		return {"key":list(lut.keys())[0], "value":list(lut.values())[0], "LT":None, "GTE":None}
	bst = {}
	keys = sorted(lut.keys())
	midPoint = math.floor(len(keys)/2)
	sortedLinenums = [lut[key] for key in keys]
	leftHalf = {key: lut[key] for key in keys[0:midPoint]}
	rightHalf = {key: lut[key] for key in keys[midPoint:]}
	bst['key'] = keys[midPoint]
	bst['value'] = lut[keys[midPoint]]
	bst['LT'] = lutToBST(leftHalf)
	bst['GTE'] = lutToBST(rightHalf)
	return bst

def printBST(bst, indent=0):
	if not bst:
		return
	print(textwrap.indent("%s: %d" % (bst['key'], bst['value']), " "*indent))
	printBST(bst['LT'], indent = indent+4)
	printBST(bst['GTE'], indent = indent+4)
	

bstSearchCode = ""

def generateBSTSearchCode(bst):
	global lineNum
	global bstSearchCode
	if not bst:
		return -1
	if bst['LT'] == None and bst['GTE'] == None:
		return bst['value']

	ltGoto = generateBSTSearchCode(bst['LT'])
	gteGoto = generateBSTSearchCode(bst['GTE'])
	nextLine = lineNum
	bstSearchCode += ("%d IF a$<CHR$ %d THEN GO TO %d\n" % (nextLine, bst['key'], ltGoto))
	bstSearchCode += ("%d GO TO %d\n" % (nextLine+1, gteGoto))	
	lineNum = nextLine+2
	return nextLine


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
bstStart = lineNum
bst = lutToBST(lut)
startLine = generateBSTSearchCode(bst)
print("%d GO SUB %d" % (gosubCallLineNum, startLine))
print("%d LPRINT CHR$ 13+CHR$ 10" % (gosubCallLineNum+1))
print("%d RETURN" % (gosubCallLineNum+2))
print(fontBlock, end='')
print(bstSearchCode, end='')


