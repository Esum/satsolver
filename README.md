# satsolver

Building
=

Requirements:

- OCaml 4.04.0 or later.
- Python 3.5 or later.
- make.

Run `make` to build the solver as optimized native code.

Usage
=

SAT-Solver
-

To solve a CNF formula you can either specify a file in DIMACS format as an argument or in stdin

- ```./satsolver formula.cnf```
- ```./satsolver < formula.cnf```

You can also run `./satsolver` and write a DIMACS formula in the prompt.


Sudoku
-

A sudoku file is a sequence of statements ```i, j: k``` separated by line feeds, meaning that there is a `k` at the intersection of column `i` and row `j`, the columns and rows are numbered from 0 to 7

To solve a sudoku run:

```./sudoku.py sudoku.txt```
