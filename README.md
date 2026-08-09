This repo contains all of my experiments with MS-DOS assembly programming.

### Setup:

86box with the following setup:

- Machine

    - Machine type: 80286

    - Machine: MR BIOS 286 clone (the original IBM PC XT/AT doesn't have BIOS setup, instead I had to use a diagnostic disk. The clones are way easier)

    - CPU Frequency: 6

    - FPU: None

    - Memory: 640KB

    - Time synchronization: Disabled

- Display

    - Video: IBM CGA

- Input devices

    - Keyboard: AT Keyboard

    - Mouse: Microsoft Serial Mouse

- Storage controllers

    - CD-ROM controller: Panasonic/MKE CD-ROM interface (I don't think this works on a 80286, so please ignore this one)

    - Hard disk controllers: PC/AY IDE Controller

- Hard disks: 10MB (C: 306, H:4, S:17, Model:3500RPM)

- Floppy: 5.25" 360k

Once boot up, press the "Press Ctrl+Alt+Esc" button to access BIOS. Setup the hard disk and others. Make sure to clone the initial setup once you install MS-DOS! It is so easy to break the machine in 16-bit real mode.

### Operating System

MS-DOS 5.0

Download from here: https://winworldpc.com/product/ms-dos/50

I use the 5-diskette 5.25-360K version.

I was a little worried about the space it may take, but apparently it was in 198x and people took it seriously. The whole installation took less than 2MB.

### Host Dev Env

Windows 10 + VSCode + NASM Code Lens (for intellisense) + Hex Editor (for checking binary)

For image transfer I use WinImage. It is a paid application but does offer 30-day of free trial. The idea is to create a new image within 86box, and use Winimage to write into the image. I can then mount the image as a 360KB diskette. Note that you need to close Winimage to mount successfully.

It is a bit hassle because the machine does not support CD-ROM, otherwise I can use the shared folder method, which requires a CD-ROM driver in the emulated env.

For cross compilation, it is a bit complicated. I use OpenWatcom 2.0, and you can refer to my link scripts and build.ps1 file for details. You should be able to drop them in directly, but remember to change the directory of OpenWatcom to your own -- that is line 9 in build.ps1. You should also change the name of the asm file in line 31, and optionally you can also change the name of the executable file in the .lnk files.

To build .COM files, put your .asm files under dos-com. To build .EXE files, put your .asm files under dos16. Press Ctrl + Shift + B and select the option you want. The executable file should appear in the build directory.

I don't have any setup for remote debugging, which is something I really need. Right now I simply debug by using DEBUG.EXE in MS-DOS, which is very limited. But it helps to be able to (R)read regusters, (A)seemble some code, and (T)race them, (D)ump memory, etc. It is probably the poor man's debugger, and is good enough for any experimental code.

I use LLM to setup the dev enviorment and recommend tools and books, but the code is all written by hand. I so far have not consulted LLM for any help regarding the code. There are plenty of examples on Stackoverflow, and I bought 3 books to help me. "Assembly Langugage Step by Step" is very helpful. I'm still waiting for the other two books.