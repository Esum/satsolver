all: opt

opt:
	ocamlopt -O3 str.cmxa intset.mli intset.ml env.mli env.ml cnf.mli cnf.ml dpll.ml -o satsolver

clean:
	rm -f *.cmi *.cmo *.cmx *.o satsolver
	rm -f sudoku.cnf sudokures.txt
	rm -f picross.cnf picrossres.txt
