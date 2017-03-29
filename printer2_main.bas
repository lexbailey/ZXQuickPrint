9 REM Disable token mode
10 COPY : REM CHR$ 0
19 REM Reset the printer
20 LPRINT CHR$ 27
25 GO TO 290
29 REM Call the function that will print the badge
30 GO SUB 200
39 REM print seven line feeds
40 FOR n=0 TO 6
50 LPRINT CHR$ 13+CHR$ 10
60 NEXT n
69 REM Cut the paper
70 LPRINT CHR$ 29+"V1"
80 RETURN
200 INPUT "Type your name", m$
205 LPRINT CHR$ 27+"!"+CHR$ 0
207 LPRINT CHR$ 27+"a0"
210 LPRINT "       Hi, my name is"
220 LPRINT CHR$ 13+CHR$ 10
229 REM Enable bold text
230 LPRINT CHR$ 27+"E1"
239 REM Large text mode
240 LPRINT CHR$ 27+"!0"
249 REM Justify centre
250 LPRINT CHR$ 27+"a1"
259 REM Print the name
260 LPRINT m$
270 LPRINT CHR$ 13+CHR$ 10
280 RETURN
289 REM Main menu
290 CLS
291 PRINT "Printer main menu"
292 PRINT " * N - Name badge"
294 PRINT " * B - Banner"
296 PRINT " * C - YHS contact card"
298 PRINT ""
299 PRINT ""
300 PRINT "Type N, B or C"
310 INPUT "Selection - ", s$
320 IF s$="n" OR s$="N" THEN GO SUB 30
330 IF s$="b" OR s$="B" THEN GO SUB 450
340 IF s$="c" OR s$="c" THEN GO SUB 370
350 IF s$="e" OR s$="E" THEN STOP
360 GO TO 290
369 REM set up printer
370 LPRINT CHR$ 27+"E1"+CHR$ 27+"!0"+CHR$ 27+"a1"
380 LPRINT "York Hackspace"+CHR$ 13+CHR$ 10
390 LPRINT CHR$ 27+"E0"+CHR$ 27+"!"+CHR$ 0
400 LPRINT "Unit 1, 35 Hospital fields road"+CHR$ 13+CHR$ 10+"York, YO10 4DZ"+CHR$ 13+CHR$ 10
410 LPRINT "@yorkhackspace"+CHR$ 13+CHR$ 10
420 LPRINT "https://york.hackspace.org.uk/"+CHR$ 13+CHR$ 10
425 LPRINT CHR$ 29+"h"+CHR$ 60
430 LPRINT CHR$ 29+"k"+CHR$ 73+CHR$ 13+CHR$ 123+CHR$ 66+"x.vu/sgDoCn"
435 GO SUB 40
440 RETURN
450 INPUT "Enter banner text", t$
455 LPRINT CHR$ 27+"E1"+CHR$ 27+"! "+CHR$ 27+"a0"
460 FOR c=1 TO LEN t$
470 LET a$=t$(c TO c)
510 GO SUB 600
520 NEXT c
530 GO SUB 40
540 RETURN
