# ==============================================================================
# math_ops_gas.s - Mathematical operations module (AT&T syntax)
# ==============================================================================
# This separate module demonstrates:
# - How code can be organized into multiple files (modular programming)
# - How the linker resolves external symbols (symbol resolution)
# - Function implementation with proper calling conventions
# - Separate compilation (only changed files need reassembly)
#
# WHY SEPARATE FILES?
# 1. Organization - group related functions together
# 2. Reusability - other programs can use these functions
# 3. Maintainability - easier to find and fix code
# 4. Collaboration - different people work on different files
# 5. Compilation speed - only reassemble changed files
#
# THE LINKING PROCESS:
# 1. Assembler creates main_gas.o with undefined "add_numbers"
# 2. Assembler creates math_ops_gas.o with defined "add_numbers"
# 3. Linker combines them and resolves the reference
# 4. Final executable has everything connected
# ==============================================================================

.section .text
    # ===========================================================================
    # TEXT SEGMENT - Contains executable code
    # ===========================================================================
    # Export these functions so main_gas.s can use them
    # .global makes symbols visible to the linker
    .global add_numbers            # Make add_numbers accessible
    .global subtract_numbers       # Make subtract_numbers accessible

# ==============================================================================
# Function: add_numbers
# Purpose: Adds two 64-bit signed integers
# Parameters (Linux x86-64 calling convention):
#   RDI = first number (addend)
#   RSI = second number (addend)
# Returns:
#   RAX = sum (RDI + RSI)
# Registers modified: RAX (return value)
# Registers preserved: All others (RBP saved/restored)
# ==============================================================================
add_numbers:
    # FUNCTION PROLOGUE - Setup
    pushq   %rbp                   # Save caller's base pointer
                                   # RBP is callee-saved, must preserve it!
    movq    %rsp, %rbp             # Set up our own stack frame
                                   # Creates stable reference point
    
    # FUNCTION BODY - The actual work
    movq    %rdi, %rax             # Copy first parameter into RAX
                                   # RAX is the return register
    addq    %rsi, %rax             # Add second parameter to RAX
                                   # ADD does: RAX = RAX + RSI
                                   # Now RAX contains the sum
    
    # FUNCTION EPILOGUE - Cleanup and return
    popq    %rbp                   # Restore caller's base pointer
    ret                            # Return to caller
                                   # Caller will find result in RAX

# ==============================================================================
# Function: subtract_numbers
# Purpose: Subtracts second number from first (computes difference)
# Parameters (Linux x86-64 calling convention):
#   RDI = first number (minuend - subtract FROM this)
#   RSI = second number (subtrahend - subtract THIS)
# Returns:
#   RAX = difference (RDI - RSI)
# Registers modified: RAX (return value)
# Registers preserved: All others (RBP saved/restored)
# Note: Can produce negative results if RSI > RDI
# ==============================================================================
subtract_numbers:
    # FUNCTION PROLOGUE - Setup
    pushq   %rbp                   # Save caller's base pointer
    movq    %rsp, %rbp             # Establish our stack frame
    
    # FUNCTION EPILOGUE - Cleanup
    popq    %rbp                   # Restore caller's base pointer
    ret                            # Return to caller
                                   # Result is in RAX

# ==============================================================================
#   
    # FUNCTION BODY - Perform the subtraction
    movq    %rdi, %rax             # Copy minuend to RAX
    subq    %rsi, %rax             # Subtract subtrahend from RAX
                                   # SUB does: RAX = RAX - RSI
                                   # Sets CPU flags: CF, OF, SF, ZF, PF
    
    # Stack visualization at this point:
    # 
    # Higher Addresses ↑
    # +----------------------+
    # | Caller's stack       |
    # +----------------------+
    # | Return address       | ← Pushed by CALL
    # +----------------------+
    # | Saved RBP            | ← Pushed by prologue
    # +----------------------+ ← RSP and RBP point here
    # Lower Addresses ↓
    #
    # Note: Stack grows downward (toward lower addresses)
    
    # FUNCTION EPILOGUE - Cleanup
    popq    %rbp                   # Restore caller's base pointer
    ret                            # Return to caller
                                   # Result is in RAX

# ==============================================================================
# Additional Educational Notes:
# ==============================================================================
# 
# CALLING CONVENTION (System V AMD64 - Linux/Unix/macOS):
# --------------------------------------------------------
# - Integer/pointer args 1-6: RDI, RSI, RDX, RCX, R8, R9
# - Floating-point args 1-8: XMM0-XMM7
# - Additional args passed on stack (right-to-left)
# - Return value in RAX (integer) or XMM0 (float)
# - Caller-saved (may be destroyed): RAX, RCX, RDX, RSI, RDI, R8-R11
# - Callee-saved (must preserve): RBX, RSP, RBP, R12-R15
# - Stack must be 16-byte aligned before CALL
#
# LINKING PROCESS (How separate files become one program):
# --------------------------------------------------------
# 1. Assembler (as) creates math_ops_gas.o:
#    - Translates assembly to machine code
#    - Creates symbol table with add_numbers and subtract_numbers
#    - Marks them as 'global' (exported)
#    - Addresses are relative (start at 0)
#
# 2. Assembler (as) creates main_gas.o:
#    - Translates main program to machine code
#    - Creates undefined references to add_numbers and subtract_numbers
#    - Leaves placeholder addresses
#
# 3. Linker (ld) combines object files:
#    - Reads symbol tables from ALL object files
#    - Matches undefined references to defined symbols
#    - Calculates final memory addresses
#    - Patches all references with correct addresses
#    - Produces final executable
#
# VIEW SYMBOLS IN OBJECT FILES:
# ----------------------------
# nm math_ops_gas.o shows:
#   0000000000000000 T add_numbers       ← 'T' = defined in text section
#   0000000000000025 T subtract_numbers
#
# nm main_gas.o shows:
#                    U add_numbers       ← 'U' = undefined (needs linking)
#                    U subtract_numbers
#   0000000000000000 T _start
#
# After linking (nm program_gas):
#   0000000000401150 T add_numbers       ← Now has absolute address!
#   0000000000401175 T subtract_numbers
#   0000000000401000 T _start
#
# WHY THIS MATTERS:
# ----------------
# This is how ALL programs work! Large programs like:
# - Web browsers (thousands of object files)
# - The Linux kernel (tens of thousands of files)
# - Games (graphics, sound, physics - each in separate modules)
# movq %rax, %rbx    mov rbx, rax
# addq $5, %rax      add rax, 5
# movq (%rax), %rbx  mov rbx, [rax]
#
# The direction is reversed! AT&T is source-to-destination,
# Intel is destination-from-source.
# ==============================================================================
