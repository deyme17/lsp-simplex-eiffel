#!/bin/bash
# test_cmd.sh

EXE_PATH="./EIFGENs/simplexeiffel/W_code/simplexeiffel.exe"
PROBLEMS_DIR="./problems"
SOLUTIONS_DIR="./solutions"

mkdir -p "$SOLUTIONS_DIR"

if [ ! -f "$EXE_PATH" ]; then
    echo "ERROR: No such a file exist: $EXE_PATH"
    exit 1
fi

if [ ! -d "$PROBLEMS_DIR" ]; then
    echo "ERROR: No such a directory exist: $PROBLEMS_DIR"
    exit 1
fi

echo "Testing starts..."
echo "===================================="

for i in {1..7}; do
    PROBLEM_FILE="$PROBLEMS_DIR/problem${i}.txt"
    
    if [ ! -f "$PROBLEM_FILE" ]; then
        continue
    fi
    
    echo "## problem${i}.txt..."
    
    # Тест з --integer
    echo "  # integer mode test..."
    $EXE_PATH --integer --verbose "$PROBLEM_FILE" > "$SOLUTIONS_DIR/solution${i}_integer.txt" 2>&1
    
    echo "  # real mode test..."
    $EXE_PATH --verbose "$PROBLEM_FILE" > "$SOLUTIONS_DIR/solution${i}_real.txt" 2>&1
done

echo "===================================="
echo "Testing is over. Results is saved in $SOLUTIONS_DIR/"