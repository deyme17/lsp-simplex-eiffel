# SimplexEiffel - LSP Violation Study

**The threat of universal polymorphism: Investigating contract violations in numeric type hierarchies**

## Overview

This project implements the Simplex method for solving Linear Programming problems in Eiffel, demonstrating how **universal polymorphism violates the Liskov Substitution Principle (LSP)** when combined with Design by Contract (DBC).

### The Core Problem

Mathematical subset relation (ℤ ⊂ ℝ) does NOT imply safe OOP inheritance (`INTEGER` inherits `REAL`). While mathematically correct, this creates a hierarchy where:

- **Base class (`REAL`)**: Precise floating-point arithmetic
- **Derived class (`INTEGER`)**: Rounds all operations
- **Result**: Derived class violates parent's mathematical contracts!

### Research Hypothesis

> "Eiffel's Design by Contract will **expose at compile-time or runtime** the LSP violations that remain hidden in languages without DBC (like C#)"

---

## Project Structure

```
SimplexEiffel/
├── kernel/                          # Numeric type hierarchy
│   ├── number.e                     # Deferred base class
│   ├── real_number.e                # Floating-point numbers
│   └── integer_number.e             # Integer with rounding (⚠️ LSP violation!)
│
├── simplex/                         # Simplex algorithm implementation
│   ├── simplex_context.e            # Data structures (dictionaries, arrays)
│   ├── simplex_solver.e             # Main algorithm (generic over NUMBER)
│   ├── simplex_io.e                 # Input/output operations
│   └── simplex_pivot.e              # Pivot operation
│
└── application/
    ├── simplex_app.e                # Main entry point
    └── command_args.e               # CLI argument parser
```

---

## Mathematical Background

### Linear Programming Problem (Canonical Form)

```
Maximize:
  z = c₁x₁ + c₂x₂ + ... + cₙxₙ

Subject to:
  a₁₁x₁ + a₁₂x₂ + ... + a₁ₙxₙ ≤ b₁
  a₂₁x₁ + a₂₂x₂ + ... + a₂ₙxₙ ≤ b₂
  ...
  aₘ₁x₁ + aₘ₂x₂ + ... + aₘₙxₙ ≤ bₘ

  xⱼ ≥ 0, j = 1..n
```

### Slack Form

After introducing slack variables `xₙ₊₁, ..., xₙ₊ₘ`:

```
z = v + Σⱼcⱼxⱼ
xₙ₊ᵢ = bᵢ - Σⱼaᵢⱼxⱼ,  i = 1..m
xⱼ ≥ 0,  j = 1..n+m
```

**Key invariants**:
- `b[i] >= 0` for all basic variables (feasibility)
- `c[j] <= 0` for all nonbasic variables (optimality)

---

## The Polymorphism Problem

### Type Hierarchy

```eiffel
deferred class NUMBER
    -- Abstract numeric type with arithmetic operations

class REAL_NUMBER
inherit
    NUMBER
    -- Implements exact floating-point arithmetic

class INTEGER_NUMBER
inherit
    REAL_NUMBER
        redefine divide, multiply, add, subtract end
    -- ⚠️ Overrides operations with ROUNDING!
```

### Contract Violation Example

```eiffel
class REAL_NUMBER
feature
    divide (other: REAL_NUMBER): REAL_NUMBER
        require
            not_zero: other.value /= 0
        do
            create Result.make (value / other.value)
        ensure
            correct: (Result.value - value / other.value).abs < 0.0001
        end
end

class INTEGER_NUMBER
inherit
    REAL_NUMBER
        redefine divide end
feature
    divide (other: INTEGER_NUMBER): INTEGER_NUMBER
        do
            create Result.make (round(value / round(other.value)))
        ensure then
            -- ❌ CANNOT satisfy parent's postcondition!
            -- Parent expects: Result ≈ value / other.value
            -- We provide: Result = round(value / round(other.value))
        end
end
```

### The Simplex Crash Scenario

```eiffel
-- Generic Simplex solver
class SIMPLEX_SOLVER [T -> REAL_NUMBER create make end]
feature
    pivot (entering: INTEGER; leaving: INTEGER)
        require
            valid_pivot: A[leaving, entering] > 0
        local
            pivot_value: T
        do
            pivot_value := b[leaving] / A[leaving, entering]  -- ❌ Rounds!
            
            -- Update all rows
            across basic_vars as i loop
                b[i.item] := b[i.item] - A[i.item, entering] * pivot_value
            end
        ensure
            feasibility: across basic_vars as i all b[i.item] >= 0 end
            -- ❌ VIOLATED with INTEGER_NUMBER due to rounding errors!
        end
end
```

---

## Research Questions

### 1. Compilation Stage
- **Q**: Will Eiffel Studio allow `INTEGER_NUMBER` to inherit from `REAL_NUMBER`?
- **Expected**: Yes (covariant redefinition is allowed)
- **Investigation**: What warnings/errors does the compiler produce?

### 2. Runtime Stage
- **Q**: Which contract will be violated first during Simplex execution?
- **Candidates**:
  - Postcondition of `divide()` - incorrect mathematical result
  - Invariant `b[i] >= 0` - negative values after rounding
  - Postcondition of `pivot()` - basis structure corruption

### 3. Contract Relaxation
- **Q**: Can we "fix" the hierarchy by weakening contracts?
- **Answer**: Yes, but then contracts become meaningless!
- **Demonstration**: Using `ensure then` instead of `ensure` to avoid conflicts

### 4. Comparison: C# vs Eiffel
- **C#**: Silently produces wrong results ✗
- **Eiffel**: Crashes with contract violation exception ✓
- **Conclusion**: DBC exposes design flaws that type systems miss

---

## Testing Methodology

To validate the hypothesis and answer the research questions, we conducted systematic testing using a suite of Linear Programming problems with varying characteristics:

- **Fractional coefficients**: Problems requiring precise division operations
- **Integer-only data**: Edge cases where rounding might not immediately cause failures
- **Degenerate cases**: Problems prone to cycling or numerical instability
- **Invalid inputs**: Testing invariant enforcement (negative b-values)
- **Multi-dimensional problems**: Complex scenarios with multiple variables and constraints

Each test case was executed in two modes:
1. **REAL_NUMBER mode**: Expected baseline behavior
2. **INTEGER_NUMBER mode** (`-i` flag): LSP violation scenario

---

## Experimental Results

| Test Case | REAL_NUMBER | INTEGER_NUMBER | Outcome |
|-----------|-------------|----------------|---------|
| Fractional LP | Success | Crash | Postcondition violation |
| Integer-only LP | Success | Success | Lucky, but unsafe |
| Fractional mixed | Success | Crash | Pivot failure |
| Degenerate case | Max-iter stop | Crash | Wrong pivot ratios |
| Negative b-values | Crash | Crash | Invariant failure |
| Multi-dimensional LP | Success | Crash | Arithmetic mismatch |

---

## Key Findings

SimplexEiffel confirms:

- Mathematical subset relations do not justify OOP inheritance
- INTEGER_NUMBER cannot satisfy REAL_NUMBER's semantic contracts
- Eiffel's Design by Contract makes the violation explicit and debuggable
- Universal polymorphism is safe only when subtype behavior strictly respects LSP

The system demonstrates how rigorous contract checking protects complex algorithms from hidden numeric failures.