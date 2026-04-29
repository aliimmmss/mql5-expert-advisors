# MQL5 Language Basics

> Source: https://www.mql5.com/en/docs/basis

The MetaQuotes Language 5 (MQL5) is an object-oriented high-level programming language intended for writing automated trading strategies, custom technical indicators for the analysis of various financial markets. It allows not only to write a variety of expert systems, designed to operate in real time, but also create their own graphical tools to help you make trade decisions.

MQL5 is based on the concept of the popular programming language C++. As compared to MQL4, the new language now has enumerations, structures, classes and event handling. By increasing the number of embedded main types, the interaction of executable programs in MQL5 with other applications through dll is now as easy as possible. MQL5 syntax is similar to the syntax of C++, and this makes it easy to translate into it programs from modern programming languages.

To help you study the MQL5 language, all topics are grouped into the following sections:

## Sections

- **Syntax** (`/en/docs/basis/syntax`)
- **Data Types** (`/en/docs/basis/types`)
- **Operations and Expressions** (`/en/docs/basis/operations`)
- **Operators** (`/en/docs/basis/operators`)
- **Functions** (`/en/docs/basis/function`)
- **Variables** (`/en/docs/basis/variables`)
- **Preprocessor** (`/en/docs/basis/preprosessor`)
- **Object-Oriented Programming** (`/en/docs/basis/oop`)
- **Namespaces** (`/en/docs/basis/namespace`)

---

## Key Language Features

### Syntax
MQL5 syntax is similar to C++. Programs are structured with:
- Preprocessor directives (`#property`, `#include`, `#define`)
- Input variables (`input`)
- Global and local variables
- Functions with defined entry points

### Data Types
MQL5 supports the following data types:

**Integer types:**
- `char` (1 byte), `short` (2 bytes), `int` (4 bytes), `long` (8 bytes)
- `uchar`, `ushort`, `uint`, `ulong` (unsigned variants)
- `datetime` (8 bytes, seconds since 01.01.1970)
- `color` (4 bytes, RGB color)
- `bool` (1 byte, true/false)

**Floating-point types:**
- `float` (4 bytes, ~6 decimal digits precision)
- `double` (8 bytes, ~15 decimal digits precision)

**String type:**
- `string` (dynamic-length character string)

**Compound types:**
- `struct` - structures
- `class` - classes (OOP)
- `enum` - enumerations
- `union` - unions

**Special types:**
- `void` - no value
- `nullptr` - null pointer

### Operators
Standard C++ operators are supported:
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Assignment: `=`, `+=`, `-=`, `*=`, `/=`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical: `&&`, `||`, `!`
- Bitwise: `&`, `|`, `^`, `~`, `<<`, `>>`
- Ternary: `condition ? true_val : false_val`
- Increment/Decrement: `++`, `--`

### Control Flow
- `if` / `else if` / `else`
- `switch` / `case` / `default`
- `for`, `while`, `do...while`
- `break`, `continue`, `return`

### Functions
```mql5
// Function declaration
int MyFunction(int param1, double param2)
{
    // function body
    return result;
}

// Functions can have default parameters
void Func(int x = 0, double y = 1.0) {}

// Overloading is supported
int Calc(int a) { return a * 2; }
double Calc(double a) { return a * 1.5; }
```

### Variables
- **Local variables**: declared inside functions, scope limited to function
- **Global variables**: declared outside functions, accessible throughout program
- **Input variables**: `input double Lots = 0.1;` - user-configurable parameters
- **Static variables**: `static int count = 0;` - retain value between calls

### Preprocessor
```mql5
#include <Trade\Trade.mqh>    // Include library
#define MAX_VALUE 100          // Define constant
#property copyright "Author"   // Program properties
#property link "https://..."
#property version "1.00"
#property strict
```

### Object-Oriented Programming
MQL5 supports full OOP:
- Classes with public/private/protected access
- Inheritance (single)
- Polymorphism via virtual functions
- Constructors and destructors
- Interfaces (abstract classes with pure virtual functions)

### Namespaces
```mql5
namespace MyNamespace
{
    int value = 10;
    void Print() { Print("MyNamespace::Print"); }
}
```

---

## MQL5 Program Types

1. **Expert Advisor (EA)** - automated trading strategy
   - Entry points: `OnInit()`, `OnDeinit()`, `OnTick()`, `OnTrade()`, etc.
   
2. **Custom Indicator** - technical indicator
   - Entry points: `OnInit()`, `OnDeinit()`, `OnCalculate()`
   
3. **Script** - single-execution program
   - Entry point: `OnStart()`
   
4. **Service** - background program without charts
   - Entry points: `OnInit()`, `OnDeinit()`
