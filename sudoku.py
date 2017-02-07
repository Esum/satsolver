#!/usr/bin/python3

import sys
import os
from itertools import product

help = """Usage : ./sudoku.py input

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

Input must be formatted as :
"(i, j, k)(i, j, k)..."
where i, j and k are integers such that 0 <= i, j <= 8 and 1 <= k <= 9, meaning that the square at position i, j is filled with k.
All spaces are ignored.
"""


def case(i, j, k):
    """Returns the variable associated 'The square at position i, j is filled with k' """
    return i*81 + j*9 + k

def value(i, j, assignment):
    return [k for k in range(1, 10) if assignment[case(i, j, k)]][0]

def tttt(i):
    i -= 1
    return (i//81, i//9%9, i%9+1)


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


def partial_eval(form, assignment):
    return [{l for l in c if not abs(l) in assignment} for c in form if not any(assignment[abs(l)] == (True if l > 0 else False) for l in c if abs(l) in assignment)]


def dimacs_of_form(form, file="sudoku.cnf"):
    m = max(max(abs(l) for l in c) for c in form)
    l = len(form)
    with open("sudoku.cnf", 'w') as file:
        file.write("p cnf "+str(m)+" "+str(l)+"\n")
        for c in form:
            for l in c:
                file.write(str(l)+" ")
            file.write("0\n")

if __name__ == '__main__':
    if len(sys.argv) == 1:
        print(help)
        exit(1)
    inp = ''.join(sys.argv[1:])
    inp = inp.replace(' ', '')
    inp = inp.replace('\n', '')
    inp = inp.replace('\t', '')
    inp = inp.split(')(')
    inp[0] = inp[0][1:]
    inp[-1] = inp[-1][:-1]
    for k in range(len(inp)):
        inp[k] = inp[k].split(',')
    assignment = {}
    for t in inp:
        i = int(t[0])
        j = int(t[1])
        k = int(t[2])
        for l in range(1, 10):
            assignment[case(i, j, l)] = False
        assignment[case(i, j, k)] = True
    form = partial_eval(sudoku_sat(), assignment)
    for c in form:
        if any(case(7, 0, k) in c or -case(7, 0, k) in c for k in range(1, 10)) and len(c)==1:
            print(tttt(abs(next(iter(c)))))
    dimacs_of_form(form)
    os.system("./satsolver sudoku.cnf > sudoku.res")
    with open("sudoku.res", 'r') as file:
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

