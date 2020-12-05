# ZXQuickPrint

ZXQuickPrint is a printing program for the ZX spectrum that allows instant printing of name badges, contact cards and banners using an Epson ESC-POS thermal receipt roll printer and a Kempston centronics interface adapter which connects to the Spectrum's expansion port.

It can print name badges, which are small strips of paper with "Hi my name is... <name_in_bold>"

It can print banners, which prints large text running from the 'top' of the paper to the 'bottom'  by printing a series of hashes and spaces to match a ttf font from the system that generated the program. At the moment it uses Libreation Mono (Bold), but you can use any font on you system, unless you have comic sans, in which case you can use almost any font on your system.

# Building

Clone the repo, cd into the repo, then...

Init submodules

    git submodule update --init --recursive

Create and source the python virtual environment

    ./mkvenv.sh
    source venv/bin/activate # or source one of the other activate scripts for other shells

Then you just need to `make printer2_autostart.tap` and you will have a tap file ready to go.

To load the tap file onto a real spectrum, you will need to convert it to a sound file you can play. This can be done with `tape2wav` which is found in the package `fuse-emulator-utils` on debian or ubuntu or in the AUR.

    sudo apt install fuse-emulator-utils # debian or ubuntu
    yay -S fuse-emulator-utils # arch AUR package (other AUR tools are available)

    tape2wav printer2_autostart.tap printer2_autostart.wav
