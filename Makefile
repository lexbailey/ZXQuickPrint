# TODO make the following line generic somehow
# so it doesn't only work on my laptop.
BAS2TAP=~/bin/bas2tap/bas2tap
BAS2TAPOPTS=-r -s"printer2"
SHITIFY=./shitifyBasic.py


%.bas.shit: %.bas
	$(SHITIFY) $<

printer2.bas: printer2_main.bas.shit font.bas
	cat $^ > $@

font.bas: generateFont.py
	./$< > $@

printer2.tap: printer2.bas
	$(BAS2TAP) $(BAS2TAPOPTS) $< $@

printer2_autostart.tap: printer2.bas
	$(BAS2TAP) -a1 $(BAS2TAPOPTS) $< $@
