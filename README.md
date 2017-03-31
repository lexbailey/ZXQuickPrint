# ZXQuickPrint

ZXQuickPrint is a printing program for the ZX spectrum that allows instant printing of name badges, contact cards and banners using an Epson ESC-POS thermal receipt roll printer and a Kempston centronics interface adapter which connects to the Spectrum's expansion port.

It can print name badges, which are small strips of paper with "Hi my name is... <name_in_bold>"

It can print contact cards (at the moment the contents of the contact card is hard coded for York Hackspace

It can print banners, which prints large text running from the 'top' of the paper to the 'bottom'  by printing a series of hashes and spaces to match a ttf font from the system that generated the program. At the moment it uses Libreation Mono (Bold), but you can use any font on you system, unless you have comic sans, in which case you can use almost any font on your system.

# Building

You will need bas2tap version 2.7, which is the version I created to deal with the odd way the printer interface needs initialising. Get it from here: https://github.com/danieljabailey/bas2tap

Then modify the makefile so it can find bas2tap (if needed)

Then you just need to `make printer2_autostart.tap` and you will have a tap file ready to go.

To load the tap file onto a real spectrum, you will need to convert it to a sound file you can play. This can be done with `tape2wav` which is found in the package `fuse-emulator-utils` on debian or ubuntu.

  sudo apt install fuse-emulator-utils

  tape2wav printer2_autostart.tap printer2_autostart.wav
