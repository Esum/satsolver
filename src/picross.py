#!/usr/bin/python3

import sys
import os
from itertools import product
from collections import defaultdict


help = """Usage: ./picross.py input

input must be formatted as:
r: n, c: m
r#i: a_1, ..., a_k
...
c#j: a_1, ..., a_k
...
where n and m are positive numbers, 0 <= i <= n-1 and 0 <= j <= m-1.
All spaces are ignored, lines starting with - are comments.
"""

rows = 0
columns = 0
variables = {}
last_variable = 0


def square(i, j):
    """Returns the variable associated to the square at position i, j"""
    global variables, last_variable
    if (i, j) in variables:
        return variables[i, j]
    else:
        last_variable += 1
        variables[i, j] = last_variable
        return last_variable

def block(k, i, j, l):
    """Returns the variable associated to the jth block at row or column i beginning at position l"""
    global variables, last_variable
    if (k, i, j, l) in variables:
        return variables[k, i, j, l]
    else:
        last_variable += 1
        variables[k, i, j, l] = last_variable
        return last_variable

def valid_fill(seq, tot, first=True):
    if len(seq) == 0:
        return {(tot,)} if tot else {tuple()}
    if tot < sum(seq) + len(seq) - 1:
        return set()
    res = set()
    for k in range(0 if first else 1, tot-seq[0]+1):
        res |= {(k, *r) for r in valid_fill(seq[1:], tot-k-seq[0], False)}
    return res

def picross_sat(r, c):
    global rows, columns
    res = []
    # Every block starts somewhere
    for i in range(rows):
        for j in range(len(r[i])):
            res.append({block('r', i, j, k) for k in range(columns-r[i][j]+1)})
    for i in range(columns):
        for j in range(len(c[i])):
            res.append({block('c', i, j, k) for k in range(rows-c[i][j]+1)})
    # Every square of a block is filled
    for i in range(rows):
        for j in range(len(r[i])):
            for k in range(columns-r[i][j]):
                for l in range(k, k+r[i][j]):
                    res.append({-block('r', i, j, k), square(i, l)})
    for i in range(columns):
        for j in range(len(c[i])):
            for k in range(rows-c[i][j]):
                for l in range(k, k+c[i][j]):
                    res.append({-block('c', i, j, k), square(l, i)})
    # Every square is in a vertical and an horizontal block
    for i in range(rows):
        for j in range(columns):
            for k in range(len(r[i])):
                res.append({-square(i, j)} | {block('r', i, k, l) for l in range(j-r[i][k], j+1) if 0 <= l < columns-r[i][k]})
            for k in range(len(c[j])):
                res.append({-square(i, j)} | {block('c', j, k, l) for l in range(i-c[j][k], i+1) if 0 <= l < rows-c[j][k]})
    # Every block starts at only one position
    for i in range(rows):
        for j in range(len(r[i])):
            for k in range(columns):
                for l in range(k+1, columns):
                    res.append({-block('r', i, j, k), -block('r', i, j, l)})
    for i in range(columns):
        for j in range(len(c[i])):
            for k in range(rows):
                for l in range(k+1, rows):
                    res.append({-block('c', i, j, k), -block('c', i, j, l)})
    # Two consecutive blocks can't overlap
    for i in range(rows):
        for j in range(len(r[i])-1):
            for l in range(columns):
                for k in range(r[i][j]+1):
                    res.append({-block('r', i, j, l), -block('r', i, j+1, l+k)})
    for i in range(columns):
        for j in range(len(c[i])-1):
            for l in range(rows):
                for k in range(c[i][j]+1):
                    res.append({-block('c', i, j, l), -block('c', i, j+1, l+k)})
    return res

def dimacs_of_form(form, filename):
    m = max(max(abs(l) for l in c) for c in form)
    l = len(form)
    with open(filename, 'w') as file:
        file.write("p cnf "+str(m)+" "+str(l)+"\n")
        for c in form:
            for l in c:
                file.write(str(l)+" ")
            file.write("0\n")

def key(d, v):
    for k in d:
        if d[k] == v:
            return k

if __name__ == '__main__':
    if len(sys.argv) == 1:
        print(help)
        exit(1)
    r = {}
    c = {}
    with open(sys.argv[1]) as input_file:
        first = True
        for line in input_file.readlines():
            if not line:
                continue
            if line[0] == '-':
                continue
            line = line.replace(' ', '')
            line = line.replace('\n', '')
            line = line.replace('\t', '')
            if not line:
                continue
            if first:
                line = line.split(',')
                line[:1] = line[0].split(':')
                line[2:3] = line[2].split(':')
                rows = int(line[1])
                columns = int(line[3])
                first = False
                continue
            line = line.split(':')
            line[:1] = line[0].split('#')
            line[2:] = line[2].split(',')
            if line[0] == 'r':
                r[int(line[1])] = [int(a) for a in line[2:] if a]
            if line[0] == 'c':
                c[int(line[1])] = [int(a) for a in line[2:] if a]
    form = picross_sat(r, c)
    print(form)
    #print(r)
    #print(c)
    #print(variables)
    print(last_variable)
    #print('\n'.join([('{'+', '.join([('' if l > 0 else '-')+str(key(variables, abs(l))) for l in clause])+'}') for clause in form]))
    dimacs_of_form(form, "picross.cnf")
    os.system("./satsolver picross.cnf > picrossres.txt 2>/dev/null")
    assignment = defaultdict(lambda: False)
    with open("picrossres.txt", 'r') as file:
        res = file.readlines()
        if len(res) == 1:
            print("Unsolvable.")
            exit(1)
        assign = res[0][6:].replace(' ', '').split(';')
        for a in assign:
            if a.isspace() or not a:
                continue
            i = a.split("=")
            assignment[int(i[0])] = i[1] == "true"
    res = [[False]*columns for _ in range(rows)]
    for i in range(rows):
        for j in range(len(r[i])):
            for l in range(columns):
                if assignment[variables['r', i, j, l]]:
                    for k in range(l, l+r[i][j]):
                        res[i][k] = True
    for i in range(columns):
        for j in range(len(c[i])):
            for l in range(rows):
                if assignment[variables['c', i, j, l]]:
                    for k in range(l, l+c[i][j]):
                        res[k][i] = True
    for a in res:
        for b in a:
            print("o" if b else " ", end=" ")
        print()
