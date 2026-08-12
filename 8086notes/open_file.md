INT 21H

### Function 3Dh - Open file
Action: 	Opens a file in the specified or default directory on the specified drive for the named file. A 16-bit handle is returned for future access.

#### On entry:
AH = 3Dh

AL = access mode, where:
- 0 = read access
- 1 = write access
- 2 = read/write access
**All other bits off**

DS.DX = Segment:offset of ASCIIZ file specification

#### Returns: 	
Carry clear if successful: AX = file handle

Carry set if unsuccessful AX = Error code as follows
- 2: File not found
- 3: Path does not exist
- 4: No handle available (too many files)
- 5: Access denied
- 0Ch: Access code invalid

#### Notes: 	
Any normal system or hidden file with a matching name will be opened by this function. On return the read/write pointer is set to zero, the start of the file.

The call fails if:
1. Any part of the path does not exist.
2. A read only file is opened for write or read/write access.

#### My notes

So before we invoke INT 21H function 3DH, we need to perform the following tasks:
- Load immediate address of the filename string (e.g. "DEMO.TXT\0") into DS:DX
    - Note that we need to use a general register, e.g. BX as the middle man
    - Note that it must be an ASCIIZ string, i.e. ends with a zero byte.
- Clear AX
- Put 0 into AL, for read onyl access
- Put 3DH into AX

Immediately after invoking function 3DH, we need to check CF.