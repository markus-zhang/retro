1. Only BP, BX, SI and DI may hold an offset for memory data (the offset in segment:offset).

2. MOV defaults to DS for the segment register -- except SP -- if SP is offset then SS is the default segment register, which makes sense as they are both talking about the stack. You can specify other segment registers, though.

3. To override the default segment register, the overriding segment register must be put in a separate line above the instruction:

-a
ES:
MOV AX,[100]

In machine code, this actually puts 26H (representing ES) before the opcode of `MOV AX,[100]`.

4. .EXE loading

Using `DEBUG` to observe the image of my program loaded in memory:

```
DS=1515 ES=1515 SS=1525 CS=1525

1515:0000 - 1515:00FF -> not sure what is there, probably the PSP because it is exactly 0x100 bytes

1515:0100 -> Starting to see "STACK!!!"

1515:0100 - 1515:02FF -> Stack of 0x200 bytes

1515:0300: "Eat at Joe's...", so this is where the strings are saved in the data segment 
```

Q1: If DS is the data segment register, why is it at 1515H, not 1545H? 1545:0000 is exactly where "Eat at Joe's..." lives, and I assume that the data segment register should point to data. Instead, DS points to the beginning of the PSP. On the other hand, SS starts at the "STACK!!!" part, so it perfectly matches what it is supposed to do -> pointing to the stack segment.