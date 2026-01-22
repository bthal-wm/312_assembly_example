# ==============================================================================
# main_gas.s - Main program in AT&T syntax (for GCC/GAS)
# ==============================================================================
# This program demonstrates fundamental assembly concepts for education:
# - Memory organization (data, bss, text segments)
# - Register operations and data movement
# - Function calls across separate object files (linking)
# - The stack and calling conventions
# - System calls for I/O
#
# AT&T Syntax differences from Intel/NASM:
# - Instructions: source, destination (opposite of Intel)
#   Example: movq %rax, %rbx means "move rax INTO rbx"
# - Register names prefixed with %
#   Example: %rax, %rbx, %rsp
# - Immediate values prefixed with $
#   Example: movq $42, %rax means "move the VALUE 42 into rax"
# - Memory addressing: offset(%base, %index, scale)
#   Example: 8(%rsp) means "memory at address: rsp + 8"
# ==============================================================================

.section .data
    # ===========================================================================
    # DATA SEGMENT - Initialized Global/Static Variables
    # ===========================================================================
    # This section contains data that:
    # - Is initialized with specific values at compile time
    # - Is stored directly IN the executable file
    # - Exists for the entire lifetime of the program
    # - Has a fixed address in memory when program loads
    # - Is typically READ-ONLY or READ-WRITE (depending on segment flags)
    #
    # The data segment uses RAM, but the initial values come from disk.
    # ===========================================================================
    
    welcome_msg:
        .ascii "Assembly Language Memory Demo\n\n"
        # .ascii directive: Declares a string of ASCII characters
        # Each character becomes one byte in memory
        # \n is the newline character (byte value 0x0A)
        
    welcome_len = . - welcome_msg
        # Calculate string length at assembly time:
        # '.' means "current address"
        # 'welcome_msg' is the starting address
        # So: current_address - start_address = length in bytes
    
    num1_msg:
        .ascii "First number: "
    num1_msg_len = . - num1_msg
    
    num2_msg:
        .ascii "Second number: "
    num2_msg_len = . - num2_msg
    
    sum_msg:
        .ascii "Sum: "
    sum_msg_len = . - sum_msg
    
    diff_msg:
        .ascii "Difference: "
    diff_msg_len = . - diff_msg
    
    newline:
        .ascii "\n"
    
    # Sample data in memory - demonstrating data types
    number1:
        .quad 55        # .quad = 64-bit integer (8 bytes, "quadword")
                        # Stored in little-endian format
                        # In memory: 2A 00 00 00 00 00 00 00
                        # This occupies addresses number1 through number1+7
                        
    number2:
        .quad 18        # Another 64-bit integer at number1+8
                        # Shows how data is laid out sequentially
                        
    result:
        .quad 0         # Space allocated and initialized to zero
                        # Will be used to store computed results
                        # Even though it's 0, it still takes space in the executable

.section .bss
    # ===========================================================================
    # BSS SEGMENT - Uninitialized Global/Static Variables
    # ===========================================================================
    # BSS stands for "Block Started by Symbol" (historical name)
    # This section contains data that:
    # - Is NOT initialized (or initialized to zero)
    # - Does NOT take space in the executable file on disk
    # - Is allocated and zeroed by the OS when program loads
    # - Saves disk space and load time
    #
    # Example: A 1MB array in BSS adds ~0 bytes to executable size,
    #          but adds 1MB to the program's memory usage at runtime
    #
    # Use BSS for: Large buffers, temporary storage, arrays
    # Use .data for: Variables that need specific initial values
    # ===========================================================================
    
    .lcomm buffer, 64
        # .lcomm = "local common" - reserves uninitialized space
        # Allocates 64 bytes of zeroed memory at runtime
        # Can be used as a temporary buffer for string operations
        
    .lcomm temp_value, 8
        # Reserves 8 bytes (one quadword) for temporary storage
        # Demonstrates that BSS can hold any size of data

.section .text
    # ===========================================================================
    # TEXT SEGMENT - Executable Code
    # ===========================================================================
    # This section contains:
    # - Machine instructions that the CPU executes
    # - Is typically marked as READ-ONLY and EXECUTABLE
    # - Cannot be modified at runtime (prevents code injection attacks)
    # - Is shared among multiple instances of the same program
    # ===========================================================================
    
    .global _start                   # Export _start symbol for linker
                                     # Entry point - where execution begins
    .extern add_numbers              # Declare external function
                                     # Defined in math_ops_gas.s
    .extern subtract_numbers         # Another external function

_start:
    # ===========================================================================
    # DEMONSTRATION 1: Working with the Data Segment and System Calls
    # ===========================================================================
    
    # Print welcome message using Linux system call
    movq    $1, %rax                # System call number for sys_write
                                    # RAX holds the syscall number
    movq    $1, %rdi                # First argument: file descriptor
                                    # 1 = stdout (the terminal)
    leaq    welcome_msg(%rip), %rsi # Second argument: pointer to string
                                    # LEA = "Load Effective Address"
                                    # %rip = position-independent code
    movq    $welcome_len, %rdx      # Third argument: number of bytes
    syscall                         # Transfer control to kernel
    
    # Load first number from memory into register
    movq    number1(%rip), %rax     # LOAD operation: Memory → Register
                                    # RAX now contains 42
    
    # Print "First number: "
    pushq   %rax                    # Save RAX on the STACK
                                    # Stack grows downward
                                    # Push: RSP = RSP - 8, store RAX at [RSP]
    movq    $1, %rax                # Prepare for sys_write
    movq    $1, %rdi                # stdout
    leaq    num1_msg(%rip), %rsi    # Message pointer
    movq    $num1_msg_len, %rdx     # Length
    syscall                         # Print the message
    popq    %rax                    # Restore RAX from stack
                                    # Pop: load from [RSP], RSP = RSP + 8
    
    # Print the number
    pushq   %rax
    call    print_number
    call    print_newline
    popq    %rax
    
    # ===========================================================================
    # DEMONSTRATION 2: Working with Multiple Registers
    # ===========================================================================
    # Registers are the CPU's fastest storage locations
    # Let's use a different register (RBX) for the second number
    # ===========================================================================
    
    # Load second number
    movq    number2(%rip), %rbx     # Load 18 into RBX
                                    # RBX is a general-purpose register
                                    # Now we have: RAX=42, RBX=18
    
    # Print "Second number: "
    pushq   %rbx
    movq    $1, %rax
    movq    $1, %rdi
    leaq    num2_msg(%rip), %rsi
    movq    $num2_msg_len, %rdx
    syscall
    popq    %rbx
    
    pushq   %rbx
    movq    %rbx, %rax
    call    print_number
    call    print_newline
    popq    %rbx
    
    # ===========================================================================
    # DEMONSTRATION 3: Function Calls and Linking
    # ===========================================================================
    # CALLING CONVENTION - Linux x86-64 (System V ABI):
    #   Arguments 1-6: RDI, RSI, RDX, RCX, R8, R9
    #   Return value: RAX
    # ===========================================================================
    
    # Prepare arguments for add_numbers
    movq    number1(%rip), %rdi     # First argument: 42 → RDI
    movq    number2(%rip), %rsi     # Second argument: 18 → RSI
    
    # Call add_numbers function from math_ops_gas.s
    # This demonstrates LINKING!
    call    add_numbers             # CALL pushes return address, jumps
                                    # Result will be in RAX when it returns
    
    # Store result back to memory
    movq    %rax, result(%rip)      # STORE operation: Register → Memory
    
    # Print sum message
    pushq   %rax
    movq    $1, %rax
    movq    $1, %rdi
    leaq    sum_msg(%rip), %rsi
    movq    $sum_msg_len, %rdx
    syscall
    popq    %rax
    
    # Print result
    call    print_number
    call    print_newline
    
    # ===========================================================================
    # DEMONSTRATION 4: Another External Function Call
    # ===========================================================================
    
    # Call subtract_numbers function
    movq    number1(%rip), %rdi
    movq    number2(%rip), %rsi
    call    subtract_numbers
    
    # Print difference message
    pushq   %rax
    movq    $1, %rax
    movq    $1, %rdi
    leaq    diff_msg(%rip), %rsi
    movq    $diff_msg_len, %rdx
    syscall
    popq    %rax
    
    # Print result
    call    print_number
    call    print_newline
    
    # ===========================================================================
    # DEMONSTRATION 5: Using the BSS Segment
    # ===========================================================================
    # BSS is for uninitialized data - doesn't take space in executable
    # ===========================================================================
    
    movq    $12345, %rax            # Load immediate value
                                    # $ means "the value 12345"
    movq    %rax, temp_value(%rip)  # Store to BSS variable
                                    # BSS is real, writable memory
    movq    temp_value(%rip), %rbx  # Load it back to verify
                                    # RBX now contains 12345
    
    # ===========================================================================
    # Exit the program cleanly
    # ===========================================================================
    movq    $60, %rax               # System call #60 = sys_exit
                                    # Tells kernel to terminate process
    xorq    %rdi, %rdi              # Set exit code to 0
                                    # XOR register with itself = 0
                                    # Exit code 0 means "success"
    syscall                         # Make the system call
                                    # Program terminates here

# ==============================================================================
# Helper function: print_number
# Converts number in RAX to ASCII and prints it
# ==============================================================================
print_number:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx
    
    subq    $32, %rsp               # Space for digits
    
    movq    $10, %rbx               # Divisor
    xorq    %rcx, %rcx              # Digit counter
    movq    %rsp, %rdi              # Buffer pointer
    
convert_loop:
    xorq    %rdx, %rdx              # Clear RDX for division
    divq    %rbx                    # RAX / 10
    addq    $'0', %rdx              # Convert to ASCII
    pushq   %rdx                    # Save digit
    incq    %rcx                    # Count digits
    testq   %rax, %rax
    jnz     convert_loop
    
print_loop:
    testq   %rcx, %rcx
    jz      done_print
    
    popq    %rdx
    movb    %dl, (%rdi)
    incq    %rdi
    decq    %rcx
    jmp     print_loop
    
done_print:
    # Calculate length
    movq    %rdi, %rdx
    subq    %rsp, %rdx
    
    # Print
    movq    $1, %rax
    pushq   %rdi
    movq    $1, %rdi
    movq    %rsp, %rsi
    addq    $8, %rsi                # Adjust for pushed RDI
    syscall
    popq    %rdi
    
    addq    $32, %rsp
    popq    %rdx
    popq    %rcx
    popq    %rbx
    popq    %rbp
    ret

# ==============================================================================
# Helper function: print_newline
# ==============================================================================
print_newline:
    pushq   %rax
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    
    movq    $1, %rax
    movq    $1, %rdi
    leaq    newline(%rip), %rsi
    movq    $1, %rdx
    syscall
    
    popq    %rdx
    popq    %rsi
    popq    %rdi
    popq    %rax
    ret
