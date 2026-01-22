#!/bin/bash
# ==============================================================================
# build_gcc.sh - Build script using GCC toolchain (AT&T syntax)
# ==============================================================================

echo "========================================"
echo "Assembly with GCC/GAS (AT&T Syntax)"
echo "========================================"
echo ""

# Clean previous build
echo "Cleaning previous build..."
rm -f main_gas.o math_ops_gas.o program_gas
echo ""

# Step 1: Assemble main_gas.s using GCC's assembler (as)
echo "Step 1: Assembling main_gas.s with GNU assembler..."
echo "Command: as main_gas.s -o main_gas.o"
as main_gas.s -o main_gas.o
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to assemble main_gas.s"
    exit 1
fi
echo "  ✓ Created main_gas.o"
echo ""

# Step 2: Assemble math_ops_gas.s
echo "Step 2: Assembling math_ops_gas.s..."
echo "Command: as math_ops_gas.s -o math_ops_gas.o"
as math_ops_gas.s -o math_ops_gas.o
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to assemble math_ops_gas.s"
    exit 1
fi
echo "  ✓ Created math_ops_gas.o"
echo ""

# Step 3: Link with ld
echo "Step 3: Linking with ld..."
echo "Command: ld main_gas.o math_ops_gas.o -o program_gas"
ld main_gas.o math_ops_gas.o -o program_gas
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to link"
    exit 1
fi
echo "  ✓ Created program_gas (executable)"
echo ""

echo "========================================"
echo "Build Successful!"
echo "========================================"
echo ""
echo "To run: ./program_gas"
echo ""
echo "To examine symbols: nm main_gas.o"
echo "To disassemble: objdump -d main_gas.o"
echo ""
