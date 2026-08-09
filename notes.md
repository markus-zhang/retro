1. When DEBUG loads a file, it keeps its count of the file's length in BX and CX register (CX is the lower 16-bit).

2. When DEBUG writes back to the file using W command, it writes back as many bytes to disk as specificed in BX and CX.

3. Segment:
- Since each segment fills a 16-bit while the memory addressing actually allows 20-bit, the remaining 4-bit gives 2^4 = 16 bytes, which is called a Paragraph. Starting from 00H, each Paragraph could serve as the beginning address of a segment. And this is also why segments actually overlap with each other.

- Each segment is of <= 64KB length.

- Segments can begin at any segment address (Paragraph). There are 1MB (2^20 bit) / 16-bit (segment address is separated by 2^4 bits starting from 00H) = 2^16 (65,536) segments in the 1MB memory address.

- Segments don't really exist physically. It is mostly a concept -- a location in memory at which the CPU's 64K blinders are positioned.

4. How to address segments:
- All 8086/8088 registers are 16-bit -- that's why they are called 16-bit machines.

- We use 2 16-bit registers for 1 20-bit memory address. And there are a lot of overlapping.

- Example: 0001H:001DH -> falls within segment 0001H, and is located 001DH bytes offset from the start of that segment.

- Now, if we use the next segment, which is 0002H, the same address is located 000DH bytes offset from the start, so 0002H:000DH points to the same address.

- We can also move backwards -- if we use the first segment, 0000H, then the offset is 002DH, because each segment is 0010H bytes apart. So 0000H:002DH points the the same address.

- In general, use segment registers (CS, DS, SS, ES) to hold the segment address, and use some general registers (BX, BP, SP, SI, DI) to hold the offset.

- CS:IP contains the 20-bit address of the next machine instruction to be executed.

5. Using DEBUG to observe memory:

- Interesting finding: This version of DEBUG (MS-DOS 5.0) wraps memory back to the bottom (0000:0000) once it goes over the maximum (FFFF:000F which is 0xFFFFF, the maximum of 1MB memory space). Try the following commands to see this:

	-d ffff:0005

	-d 0000:0000 (should show almost identical)

- FFFF:0000 contains a JMP instruction for IBM PC and clones. When the PC boots, it starts in real mode and executes the instruction at FFFF:0000. If press G, the PC cold boots, because this is how the PC is brought up from a cold boot.

6. To read a file, use INT 21H + 3FH, looks like it requires a file handler, so there must be something other routine that opens a file and returns a file handler, like in Unix. Yeah that's function 3DH.