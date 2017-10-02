REM Initialisation
REM Disable token mode
COPY : REM CHR$ 0
CLEAR 29100
LET o=29100
LET p=o+190
DIM e(95)
REM Default font name
LET h$="font"
GO SUB loadfont
GO SUB load_inflate_code
LET f$=CHR$13+CHR$10
LET t$=CHR$27
LABEL: mainmenu
REM Reset the printer
LPRINT t$ + "@"
CLS
BEEP 0.1, 23
BEEP 0.1, 20
BEEP 0.1, 26
BEEP 0.1, 29
PRINT "Printer main menu"
PRINT " * N - Name badge"
PRINT " * B - Banner"
PRINT " * C - YHS contact card"
PRINT " * F - Load a different font"
PRINT ""
PRINT ""
PRINT "Type N, B, C or F"
LABEL: inputloop
LET s$=INKEY$
IF s$="" THEN GO TO inputloop
LABEL: waitloop
IF INKEY$<>"" THEN GO TO waitloop
IF s$="n" OR s$="N" THEN GO SUB printbadge
IF s$="b" OR s$="B" THEN GO SUB banner
IF s$="c" OR s$="C" THEN GO SUB contactcard
IF s$="f" OR s$="F" THEN GO SUB newfont
IF s$="e" OR s$="E" THEN STOP
GO TO mainmenu

LABEL: newfont
INPUT "Type the font file name...", h$
GO SUB loadfont
RETURN

REM print seven line feeds
LABEL: feed
FOR n=0 TO 6
LPRINT f$
NEXT n
REM Cut the paper
LPRINT CHR$ 29+"V1"
RETURN

REM print a badge
LABEL: printbadge
INPUT "Type your name", m$
LPRINT t$+"!"+CHR$0+t$+"a0       Hi, my name is"+f$
REM Large bold text, centre justify
LPRINT t$+"E1"+t$+"!0"+t$+"a1"
REM Print the name
LPRINT m$+f$
GO SUB feed
RETURN

LABEL: contactcard
LPRINT t$+"E1"+t$+"!0"+t$+"a1"
LPRINT "York Hackspace"+f$
LPRINT t$+"E0"+t$+"!"+CHR$ 0
LPRINT "Unit 1, 35 Hospital Fields Road"+f$+"York, YO10 4DZ"+f$
LPRINT "@yorkhackspace"+f$
LPRINT "https://york.hackspace.org.uk/"+f$
LPRINT CHR$ 29+"h"+CHR$ 60
LPRINT CHR$ 29+"k"+CHR$ 73+CHR$ 13+CHR$ 123+CHR$ 66+"yhs.mod3.uk"
GO SUB feed
RETURN

LABEL: banner
INPUT "Enter banner text", b$
LPRINT t$+"E1"+t$+"! "+t$+"a0"
FOR c=1 TO LEN b$
LET a$=b$(c TO c)
GO SUB printchar
NEXT c
GO SUB feed
RETURN

LABEL: printchar
LET i=CODE a$-31
LET v=p
LET v=p+e(i)
LABEL: printchar_next
REM "Poke the mark and the space characters"
POKE 32575, 219
POKE 32576, 32
POKE 32597, PEEK v
POKE 32598, PEEK (v+1)
POKE 32599, PEEK (v+2)
LET v=v+3
LET r=USR 32475
IF r=0 THEN GO TO printchar_next
LPRINT f$
LPRINT f$
RETURN

LABEL: loadfont
PRINT "Loading font file"
PRINT "Please wait..."
REM Load the font file from the tape
LOAD h$ CODE
PRINT "Loading character index"
PRINT "Please wait..."
DIM e(95)
FOR i=1 TO 95
LET e(i)=(PEEK (o+(2*(i-1))))+((PEEK (o+(2*(i-1))+1))*256)
NEXT i
RETURN

LABEL: load_inflate_code
LOADASMDATA 32475 inflate_and_print
RETURN

ASMDATASTART inflate_and_print
# First we inflate the line
# Build a stack of the character data to inflate
010000   # ld bc, 0           ; A 0 to indicate the end of the data
C5       # push bc            ; push the 0 on to the stack
# Third character to inflate
3A577F   # ld a, (0x7F57)     ; a <= data[2]
4f       # ld c, a            ; c <= a
0605     # ld b, 5            ; b <= 5
C5       # push bc
# Second character to inflate
3A567F   # ld a, (0x7F56)     ; a <= data[1]
4f       # ld c, a            ; c <= a
0608     # ld b, 8            ; b <= 8
C5       # push bc
# First character to inflate
3A557F   # ld a, (0x7F55)     ; a <= data[0]
0608     # ld b, 8            ; b <= 8
213F7F   # ld hl, 7F3F        ; hl <= string-address
ED5B3F7F # ld de, (7F3F)      ; d <= mark-char, e <= space-char
# inflateloop:
CB27     # sla a              ; a <= a<<1, f.c <= a[7]
72       # ld (hl), d
3001     # jr nc skipmark
73       # ld (hl), e
# skipmark:
23       # inc hl
10F7     # djnz inflateloop
C1       # pop bc             ; get the next data char
78       # ld a, b            ; copy b to a
B7       # or a               ; bitwise or (to set zero flag)
79       # ld a, c            ; copy c to a, ready to inflate
20EF     # jr nz, inflateloop ; inflate again if needed

# Then we print to the run length
3A577F   # ld a, (0x7F57)     ; a <= data[2]
0603     # ld b, 3            ; mask for run length bits
A0       # and b              ; apply the mask
3C       # inc a              ; a += 1
47       # ld b, a            ; b <= a
3E03     # ld a, 3            ; select the printer channel
CD0116   # call 5633          ; open channel
# printloop:
C5       # push bc
113f7F   # ld de, 0x7f3f      ; address of string
011500   # ld bc, 21          ; length of string to print
CD3C20   # call 8252          ; print our string
C1       # pop bc
10F3     # djnz printloop     ; repeat for run length

# Then we calculate a return value
010100   # ld bc, 1           ; set return value to 1
3A577F   # ld a, (0x7F57)     ; a <= data[2]
1604     # ld d, 4            ; mask for stop bit
A2       # and d              ; apply the mask
2003     # jr nz, endflagset  ; if not zero, skip next instruction
010000   # ld bc, 0           ; set return value to 0
# endflagset:
C9       # ret                ; return to BASIC
ASMDATAEND
