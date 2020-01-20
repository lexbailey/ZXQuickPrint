# TODO make the following line generic somehow
# so it doesn't only work on my laptop.
BAS2TAP=./bas2tap/bas2tap
BIN2TAP=./bin2tap/bin2tap
BAS2TAPOPTS=-r -s"printer2"
SHITIFY=./shitifyBasic.py
DEFAULT_FONT=/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf
FONTLOCATION=29100
DEBUG=

default: fulltape.tap

bin2tap/bin2tap:
	$(MAKE) bin2tap -C bin2tap

bas2tap/bas2tap:
	$(MAKE) bas2tap -C bas2tap

%.bas.shit: %.bas $(SHITIFY)
	$(SHITIFY) $< $(DEBUG)

printer2.bas: printer2_main.bas.shit
	cat $^ > $@

fontdata.dat: generateFont.py
	./$< $(DEFAULT_FONT) -o $@

printer2.tap: printer2.bas bas2tap/bas2tap
	$(BAS2TAP) $(BAS2TAPOPTS) $< $@

printer2_autostart.tap: printer2.bas bas2tap/bas2tap
	$(BAS2TAP) -a1 $(BAS2TAPOPTS) $< $@

default_font.tap: fontdata.dat bin2tap/bin2tap
	$(BIN2TAP) $(FONTLOCATION) "font" $<
	mv $<.tap $@

altfonts/%_altfont.dat.tap: altfonts/%_altfont.dat bin2tap/bin2tap
	$(BIN2TAP) $(FONTLOCATION) "$(subst _altfont.dat.tap,,$(notdir $@))" $<

fulltape.tap: printer2_autostart.tap default_font.tap
	cat $^ > $@

allfonts.tap: generateFont.py
	mkdir -p altfonts
	-cd altfonts && fc-list | grep .ttf | grep -iv "Comic Sans" | grep -iv "Kacst" | grep -iv "ume-" | grep -iv "lklug" | sed -e "s/^\([^:]*\).*/\\1/" | xargs -n1 ../$<
	-ls altfonts/*.dat | xargs -I{} -n1 make altfonts/{}.tap
	cat altfonts/*.tap > allfonts.tap

megatape.tap: fulltape.tap allfonts.tap
	cat $^ > $@

.PHONY: bin2tap/bin2tap
