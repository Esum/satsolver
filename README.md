# satsolver

Benjamin Graillot
-

Compilation
=

Dépendances :

- OCaml 4.04.0 ou supérieur (certaines fonctions utilisées ne sont pas présentes dans les versions antérieures).
- make.
- Python 3.5 ou supérieur pour la compilation.

La commande `make` compile le solveur sat en binaire natif optimisé. La fonction de choix par défaut prend le littéral avec le plus grand nombre d'occurence.

Utilisation
=


SAT-Solver
-

Pour résoudre une formule CNF au format dimacs on peut la spécifier en argument au programme ou sur stdin :

- ```./satsolver formula.cnf```
- ```./satsolver < formula.cnf```

Il est également possible de lancer le programme sans argument et d'écrire une formule au format DIMACS.


Sudoku
-

Un fichier de sudoku est une suite d'entrées ```i, j: k``` séparées par des sauts de ligne, chacune signifiant qu'un $k$ est pésent à l'intersection de la colonne $i$ et de la ligne $j$, numérotées de $0$ à $8$.

Pour résoudre un sudoku la commande est :

```./sudoku.py sudoku.txt```

Picross
-
Un fichier picross est composé de :

- un header ```r: i, c: j``` où $i$ est le nomber de lignes et $j$ est le nombre de colonnes.
- une suite d'entrées ```r#i: a_1, ..., a_k``` et ```c#i: a_1, ..., a_k``` où $i$ est le nombre de la ligne (si l'entrée commence par r) ou de la colonne (si l'entrée commence par c) numérotée à partir de $0$ et $a_1,\dots,a_k$ est la suite d'indice pour cette ligne/colonne.

Pour résoudre un picross la commande est :

```./picross.py picross.txt```


Réductions
=

Sudoku
-

Dans la réduction du sudoku une variable représente la proposition $\mathrm{case}(i, j) = k$, la formule de base contient les clauses suivantes :

- Dans chaque case, il doit y avoir au moins un chiffre.
- Dans chaque case, il doit y avoir au plus un chiffre.
- Dans chaque ligne, il ne peut y avoir $2$ fois le même chiffre.
- Dans chaque colonne, il ne peut y avoir $2$ fois le même chiffre.
- Dans chaque carré, il ne peut y avoir $2$ fois le même chiffre.

Picross
-

L'implémentation actuelle semble avoir quelques problèmes cependant voici la procédure de réduction.

L'utilisation des seules variables "$\mathrm{case}(i, j)$ est noircie" donne une formule beaucoup trop grande, on utilise donc des variables supplémentaires qui donnent la première case de chaque bloc pour les lignes et les colonnes, on a ainsi les clauses suivantes :

- Chaque bloc commence avant la fin de la ligne/colonne moins sa taille.
- Chaque bloc commence à un seul endroit.
- Deux blocs ne se touchent pas.
- Chaque carré d'un bloc est noirci.
- Chaque carré est dans un bloc horizontal et un bloc vertical.


Résultats
=

Les fichiers utilisés sont dans le répertoire `examples`.

SAT-Solver
-

| fonction/fichier         | ssa6288-047.cnf | bw_large.a.cnf | 2sat1.cnf |
|--------------------------|-----------------|----------------|-----------|
| $1^\mathrm{er}$ littéral | 3.00 $s$        | 9.34 $s$       | 0.48 $s$  |
| Max occurence            | 3.09 $s$        | 5.48 $s$       | 0.34 $s$  |

En général le chaix du littéral avec le maximum d'occurence donne les meilleurs résultats pour les formules les plus grandes.

Sudoku
-

| fonction/fichier         | sudoku_36_1.txt | sudoku_28_1.txt |
|--------------------------|-----------------|-----------------|
| $1^\mathrm{er}$ littéral | 0.28 $s$        | 0.51 $s$        |
| Max occurence            | 0.23 $s$        | 2.55 $s$        |

(`sudoku_x_y.txt` : sudoku avec $x$ indices)

Pour la formule du sudoku le choix du premier littéral donne de meilleures performances.
