REM Initialisation
REM Disable token mode
COPY : REM CHR$ 0
GO SUB loadfont
GO SUB load_inflate_code
LABEL: mainmenu
REM Reset the printer
LPRINT CHR$ 27 + "@"
CLS
BEEP 0.1, 23
BEEP 0.1, 20
BEEP 0.1, 26
BEEP 0.1, 29
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

REM print seven line feeds
LABEL: feed
FOR n=0 TO 6
LPRINT CHR$ 13+CHR$ 10
NEXT n
REM Cut the paper
LPRINT CHR$ 29+"V1"
RETURN

REM print a badge
LABEL: printbadge
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
GO SUB feed
RETURN

LABEL: contactcard
LPRINT CHR$ 27+"E1"+CHR$ 27+"!0"+CHR$ 27+"a1"
LPRINT "York Hackspace"+CHR$ 13+CHR$ 10
LPRINT CHR$ 27+"E0"+CHR$ 27+"!"+CHR$ 0
LPRINT "Unit 1, 35 Hospital Fields Road"+CHR$ 13+CHR$ 10+"York, YO10 4DZ"+CHR$ 13+CHR$ 10
LPRINT "@yorkhackspace"+CHR$ 13+CHR$ 10
LPRINT "https://york.hackspace.org.uk/"+CHR$ 13+CHR$ 10
LPRINT CHR$ 29+"h"+CHR$ 60
LPRINT CHR$ 29+"k"+CHR$ 73+CHR$ 13+CHR$ 123+CHR$ 66+"ERROR ERROR"
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
LET i= CODE a$-31
LET charAddr=28000+e(i)
LABEL: printchar_next
POKE 32597, PEEK charAddr
POKE 32598, PEEK charAddr+1
POKE 32599, PEEK charAddr+2
LET charAddr= charAddr+1
LET r=USR 32475
IF r=0 THEN GO TO printchar_next
RETURN

REM read the line number data for the font into array e
LABEL: loadfont
PRINT "Loading font file"
PRINT "please wait..."
LOAD "font"CODE
GO TO RAWLINE:600

LABEL: load_inflate_code
CLEAR 32474
LOADASMDATA 32475 inflate_and_print
REM "Poke the mark and the space characters"
POKE 32575, 219
POKE 32576, 32
RETURN

ASMDATASTART inflate_and_print
# First we inflate the line
ED5B3F7F # ld de, (7F3F)      ; d <= mark-char, e <= space-char
213F7F   # ld hl, 7F3F        ; hl <= string-address
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
011600   # ld bc, 22          ; length of string to print
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
