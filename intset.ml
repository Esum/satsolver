module IntSet = Set.Make(
    struct
        let compare = Pervasives.compare
        type t = int
    end )

let string_of_intset e =
    let rec string_of_intset = function
        | s when IntSet.is_empty s -> "}"
        | e ->
            let x = IntSet.choose e in (string_of_int x)^", "^(string_of_intset (IntSet.remove x e)) in
    "{"^(string_of_intset e)

let print_intset e = print_string (string_of_intset e); print_string "\n"

module IntSetSet = Set.Make(
    struct
        let rec compare e f = match e, f with
            | s, t when s = IntSet.empty && t = IntSet.empty -> 0
            | _, s when s = IntSet.empty -> 1
            | s, _ when s = IntSet.empty -> -1
            | _, _ when e = f -> 0
            | _, _ ->
                let m = IntSet.max_elt e in
                let n = IntSet.max_elt f in
                match Pervasives.compare m n with
                | 1 -> 1
                | -1 -> -1
                | 0 -> compare (IntSet.remove m e) (IntSet.remove n f)
                | _ -> failwith ""
        type t = IntSet.t
    end )

let string_of_intsetset e =
    let rec string_of_intsetset = function
        | s when s = IntSetSet.empty -> "}"
        | e ->
            let x = IntSetSet.choose e in
            match e with
                | s when s = IntSetSet.singleton x -> (string_of_intset x)^"}"
                | _ -> (string_of_intset x)^", "^(string_of_intsetset (IntSetSet.remove x e)) in
    "{"^(string_of_intsetset e)

let print_intsetset e = print_string (string_of_intsetset e); print_string "\n"
