# Assembly Language Example: Memory Operations and Linking

## Overview
This educational example demonstrates fundamental assembly language concepts including:
- Memory manipulation (stack and data segments)
- Register operations
- Function calls and the calling convention
- Separate compilation and linking
- How the assembler and linker work together

## Files Included
- `main.asm` - Main program demonstrating memory operations
- `math_ops.asm` - Separate module with mathematical functions (demonstrates linking)
- `build.bat` - Windows batch file to assemble and link
- `build.sh` - Linux/Mac shell script to assemble and link

## Prerequisites
### Windows
- NASM (Netwide Assembler): Download from https://www.nasm.us/
- Visual Studio (for link.exe) or MinGW-w64 (for ld)

### Linux/Mac
- NASM: `sudo apt install nasm` (Ubuntu) or `brew install nasm` (Mac)
- GCC toolchain (includes ld linker)

## How It Works

### 1. Assembly Process
The assembler (NASM) converts assembly source code into object files:
```
main.asm → [NASM] → main.obj (Windows) or main.o (Linux)
math_ops.asm → [NASM] → math_ops.obj/o
```

### 2. Linking Process
The linker combines object files and resolves external references:
```
main.obj + math_ops.obj → [LINKER] → program.exe
```

### 3. Memory Segments
- **Text Segment (.text)**: Contains executable code
- **Data Segment (.data)**: Contains initialized data
- **BSS Segment (.bss)**: Contains uninitialized data
- **Stack**: Used for local variables and function calls

## Building and Running

### Windows
```batch
build.bat
program.exe
```

### Linux/Mac
```bash
chmod +x build.sh
./build.sh
./program
```

## Key Concepts Demonstrated

### Memory Operations
1. **Stack Operations**: PUSH/POP for function calls
2. **Data Movement**: MOV instructions between registers and memory
3. **Memory Addressing**: Direct, indirect, and indexed addressing modes

### Register Usage (x86-64)
- **RAX**: Accumulator, return values
- **RBX, RCX, RDX**: General purpose
- **RSI, RDI**: Source/Destination for string operations
- **RSP**: Stack pointer
- **RBP**: Base pointer (frame pointer)

### Calling Convention (System V AMD64 for Linux, Microsoft x64 for Windows)
- **Linux**: Arguments in RDI, RSI, RDX, RCX, R8, R9
- **Windows**: Arguments in RCX, RDX, R8, R9
- Return value in RAX

## Exercises for Students

1. Modify `math_ops.asm` to add a new function (e.g., multiply)
2. Add a new `.data` variable and manipulate it in `main.asm`
3. Trace the stack operations during function calls
4. Experiment with different memory addressing modes
5. Use a debugger (GDB on Linux, WinDbg on Windows) to step through the code

## Educational Notes

### Why Separate Files?
Real-world programs consist of many modules. Separate compilation allows:
- Code organization and reusability
- Faster rebuilds (only changed files are reassembled)
- Team collaboration (different developers work on different modules)

### Symbol Resolution
When `main.asm` calls a function from `math_ops.asm`:
1. Assembler creates an undefined symbol reference
2. Linker searches all object files for the symbol definition
3. Linker replaces the reference with the actual address

### Memory Layout at Runtime
```
High Address
+------------------+
|      Stack       | (grows downward)
|        ↓         |
+------------------+
|                  |
|       ...        |
|                  |
+------------------+
|        ↑         |
|      Heap        | (grows upward)
+------------------+
|   BSS Segment    | (uninitialized data)
+------------------+
|   Data Segment   | (initialized data)
+------------------+
|   Text Segment   | (program code)
+------------------+
Low Address
```

## Debugging Tips
- Use `objdump -d` (Linux) or `dumpbin /disasm` (Windows) to examine object files
- Use `nm` (Linux) or `dumpbin /symbols` (Windows) to see symbol tables
- Use GDB or WinDbg to step through assembly code at runtime

## License
This educational material is provided for academic use.
