#!/usr/bin/python3

import sys
import os
from itertools import product


help = """Usage: ./sudoku.py input

Positions i and j are defined as the following:

 i 0 1 2 3 4 5 6 7 8
j
  +-+-+-+-+-+-+-+-+-+
0 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
1 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
2 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
3 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
4 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
5 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
6 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
7 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+
8 | | | | | | | | | |
  +-+-+-+-+-+-+-+-+-+

input must be a file with the following format:
i, j: k
i, j: k
...
where i, j and k are integers such that 0 <= i, j <= 8 and 1 <= k <= 9, meaning that the square at position i, j is filled with k.
All spaces are ignored, lines starting with - are comments.
"""


def case(i, j, k):
    """Returns the variable associated 'The square at position i, j is filled with k' """
    return i*81 + j*9 + k

def value(i, j, assignment):
    return [k for k in range(1, 10) if assignment[case(i, j, k)]][0]

def sudoku_sat():
    res = []
    # Every square must be filled
    for i, j in product(range(9), repeat=2):
        res.append({case(i, j, k) for k in range(1, 10)})
    # Only one number is in a square
    for k in range(1, 10):
        for i, j in product(range(9), repeat=2):
            res.append({-case(i, j, l) for l in range(1, 10) if l != k} | {case(i, j, k)})
    # Two numbers in the same column cannot be equal
    for k in range(1, 10):
        for i in range(9):
            for j1, j2 in product(range(9), repeat=2):
                if j1 >= j2:
                    continue
                res.append({-case(i, j1, k), -case(i, j2, k)})
    # Two numbers in the same row cannot be equal:
    for k in range(1, 10):
        for j in range(9):
            for i1, i2 in product(range(9), repeat=2):
                if i1 >= i2:
                    continue
                res.append({-case(i1, j, k), -case(i2, j, k)})
    # Two numbers in the same subgrid cannot be equal:
    for k in range(1, 10):
        for subsquare in range(9):
            subsq_i, subsq_j = divmod(subsquare, 3)
            for (i1, j1), (i2, j2) in product(product(range(3*subsq_i, 3*subsq_i+3), range(3*subsq_j, 3*subsq_j+3)), repeat=2):
                if i1 >= i2 and j1 >= j2:
                    continue
                res.append({-case(i1, j1, k), -case(i2, j2, k)})
    return res

def dimacs_of_form(form, filename):
    """Write the formula form in DIMACS format in filename"""
    m = max(max(abs(l) for l in c) for c in form)
    l = len(form)
    with open(filename, 'w') as file:
        file.write("p cnf "+str(m)+" "+str(l)+"\n")
        for c in form:
            for l in c:
                file.write(str(l)+" ")
            file.write("0\n")


if __name__ == '__main__':
    if len(sys.argv) == 1:
        print(help)
        exit(1)
    assignment = []
    with open(sys.argv[1]) as input_file:
        for line in input_file.readlines():
            if not line:
                continue
            if line[0] == '-':
                continue
            line = line.replace(' ', '')
            line = line.replace('\n', '')
            line = line.replace('\t', '')
            line = line.split(':')
            line[:1] = line[0].split(',')
            line = [int(i) for i in line]
            assignment.append({case(*tuple(line))})
    dimacs_of_form(assignment + sudoku_sat(), "sudoku.cnf")
    os.system("./satsolver sudoku.cnf > sudokures.txt")
    assignment = {}
    with open("sudokures.txt", 'r') as file:
        res = file.readlines()
        if len(res) == 1:
            print("Unsolvable.")
        assign = res[0][6:].replace(' ', '').split(';')
        for a in assign:
            if a.isspace() or not a:
                continue
            i = a.split("=")
            assignment[int(i[0])] = i[1] == "true"
    for i in range(9):
         for j in range(9):
             print(value(j, i, assignment), end=" ")
         print()
