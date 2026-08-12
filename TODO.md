1. Research how CGA 320x240 graphics works, and what is the memory layout. I believe it is NOT contigous, but interlaced.

2. Research the following MS-DOS programming techniques:
    - How to load a file into memory
        - Step 1: How to open a file? Check out openfile.asm and open_file.md
    - How should I layout my application's memory? For example, let's say we have some 590KB free memory, and I need to load some 200KB into memory, how do I setup segment registers for these 200KB? Should I hardcode the segment registers, or does MS-DOS arrange this for me?
    - How to open a file and obtain a file handler?
    - How to obtain the size of the file opened?
    - How to use the ^ mentioned file handler to read X bytes into memory?

3. Research asset compression in assembly:
    - Run-length encoding is perhaps suitable for CGA graphics because we only have 4 colors.

4. How to make CGA graphics like spritesheets?
    