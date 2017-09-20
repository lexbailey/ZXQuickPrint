DIM e(95)
RESTORE
FOR n=1 TO 95: READ e(n): NEXT n
REM Disable token mode
COPY : REM CHR$ 0
REM Reset the printer
LPRINT CHR$ 27 + "@"
BEEP 1, 0
GO TO mainmenu
REM Call the function that will print the badge
LABEL: printbadge
GO SUB printname
REM print seven line feeds
LABEL: feed
FOR n=0 TO 6
LPRINT CHR$ 13+CHR$ 10
NEXT n
REM Cut the paper
LPRINT CHR$ 29+"V1"
RETURN
LABEL: printname
INPUT "Type your name", m$
LPRINT CHR$ 27+"!"+CHR$ 0
LPRINT CHR$ 27+"a0"
LPRINT "       Hi, my name is"
LPRINT CHR$ 13+CHR$ 10
REM Enable bold text
LPRINT CHR$ 27+"E1"
REM Large text mode
LPRINT CHR$ 27+"!0"
REM Justify centre
LPRINT CHR$ 27+"a1"
REM Print the name
LPRINT m$
LPRINT CHR$ 13+CHR$ 10
RETURN
REM Main menu
LABEL: mainmenu
CLS
PRINT "Printer main menu"
PRINT " * N - Name badge"
PRINT " * B - Banner"
PRINT " * C - YHS contact card"
PRINT ""
PRINT ""
PRINT "Type N, B or C"
LABEL: inputloop
LET s$=INKEY$
IF s$="" THEN GO TO inputloop
LABEL: waitloop
IF INKEY$<>"" THEN GO TO waitloop
IF s$="n" OR s$="N" THEN GO SUB printbadge
IF s$="b" OR s$="B" THEN GO SUB banner
IF s$="c" OR s$="c" THEN GO SUB contactcard
IF s$="e" OR s$="E" THEN STOP
GO TO mainmenu
REM set up printer
LABEL: contactcard
LPRINT CHR$ 27+"E1"+CHR$ 27+"!0"+CHR$ 27+"a1"
LPRINT "York Hackspace"+CHR$ 13+CHR$ 10
LPRINT CHR$ 27+"E0"+CHR$ 27+"!"+CHR$ 0
LPRINT "Unit 1, 35 Hospital Fields Road"+CHR$ 13+CHR$ 10+"York, YO10 4DZ"+CHR$ 13+CHR$ 10
LPRINT "@yorkhackspace"+CHR$ 13+CHR$ 10
LPRINT "https://york.hackspace.org.uk/"+CHR$ 13+CHR$ 10
LPRINT CHR$ 29+"h"+CHR$ 60
LPRINT CHR$ 29+"k"+CHR$ 73+CHR$ 13+CHR$ 123+CHR$ 66+"x.vu/sgDoCn"
GO SUB feed
RETURN
LABEL: banner
INPUT "Enter banner text", t$
LPRINT CHR$ 27+"E1"+CHR$ 27+"! "+CHR$ 27+"a0"
FOR c=1 TO LEN t$
LET a$=t$(c TO c)
GO SUB printchar
NEXT c
GO SUB feed
RETURN
LABEL: printchar
GO TO RAWLINE:600
