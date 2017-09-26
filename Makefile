# TODO make the following line generic somehow
# so it doesn't only work on my laptop.
BAS2TAP=~/bin/bas2tap/bas2tap
BAS2TAPOPTS=-r -s"printer2"
SHITIFY=./shitifyBasic.py
DEFAULT_FONT=/usr/share/fonts/truetype/roboto/hinted/RobotoCondensed-Regular.ttf


%.bas.shit: %.bas
	$(SHITIFY) $<

printer2.bas: printer2_main.bas.shit font.bas
	cat $^ > $@

font.bas: generateFont.py
	./$< $(DEFAULT_FONT) > $@

printer2.tap: printer2.bas
	$(BAS2TAP) $(BAS2TAPOPTS) $< $@

printer2_autostart.tap: printer2.bas
	$(BAS2TAP) -a1 $(BAS2TAPOPTS) $< $@

default_font.tap: fontdata.dat bin2tap/bin2tap
	./$(word 2,$^) 30000 "font" $<
	mv $<.tap $@

fulltape.tap: printer2_autostart.tap default_font.tap
	cat $^ > $@

allfonts: generateFont.py
	fc-list | grep .ttf | grep -iv "Comic Sans" | sed -e "s/^\([^:]*\).*/\\1/" | xargs -n1 ./$<

.PHONY: allfonts
