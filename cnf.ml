module Clause =
struct
    type literal = int
    let compare_literals l l' = match abs l, abs l' with
        | a, b when a = b -> Pervasives.compare l' l
        | a, b -> Pervasives.compare b a
    type t = literal list
    let empty = []
    let length = List.length
    let check_length n c =
        let rec check_length len = function
            | [] -> len = n
            | h::t when len < n -> check_length (len+1) t
            | _ -> false in
        check_length 0 c
    let choose = List.hd
    let map = List.map
    let fold = List.fold_left
    let iter = List.iter
    let for_all = List.for_all
    let exists = List.exists
    let find = List.find
    let rec mem l = function
        | h::_ when h = l -> true
        | h::_ when compare_literals h l > 0 -> false
        | _::t -> mem l t
        | _ -> false
    let rec remove l = function
        | h::t when h = l -> t
        | h::t when compare_literals h l > 0 -> h::t
        | h::t -> h::(remove l t)
        | _ -> []
    let filter = List.filter
    let of_literal l = [l]
    let of_list = List.sort_uniq compare_literals
    let literals c = c
    let rec propositions c = match c with
        | h::h'::t when h = (-h') -> h::(propositions t)
        | h::t -> (abs h)::(propositions t)
        | [] -> []
    let max_proposition c = abs (List.hd c)
end

let string_of_clause c =
    let rec string_of_clause = function
        | h::[] -> (string_of_int h)^"}"
        | h::t -> (string_of_int h)^", "^(string_of_clause t)
        | _ -> "}" in
    "{"^(string_of_clause c)

module Cnf =
struct
    type t = Clause.t list
    let is_empty = (=) []
    let choose = List.hd
    let add_clause = fun h t -> h::t
    let map = List.map
    let fold = List.fold_left
    let iter = List.iter
    let for_all = List.for_all
    let exists = List.exists
    let mem l = List.exists (Clause.mem l)
    let remove l = List.map (Clause.remove l)
    let find = List.find
    let find_some pred f = try Some (find pred f) with Not_found -> None
    let filter = List.filter
    let rec filter_map f = function
        | h::t -> ( match f h with
            | Some a -> a::(filter_map f t)
            | _ -> filter_map f t )
        | _ -> []
    let of_list f = f
    let literals =
        let rec merge_uniq c c' = match c, c' with
            | h::t, h'::t' when h = h' -> h::(merge_uniq t t')
            | h::t, h'::t' when Clause.compare_literals h h' > 0 -> h::(merge_uniq t c')
            | h::t, h'::t' when Clause.compare_literals h h' < 0 -> h'::(merge_uniq c t')
            | c, [] -> c
            | _, _ -> c' in
        List.fold_left merge_uniq []
    let max_proposition = List.fold_left (fun m c -> max m (Clause.max_proposition c)) 0

    let partial_evaluation form env =
        let rec partial_evaluation = function
            | [] -> []
            | c::t -> match Clause.exists (fun l -> match env l with Some true -> true | _ -> false) c with
                | true -> partial_evaluation t
                | false -> (Clause.filter (fun l -> match env l with None -> true | _ -> false) c)::(partial_evaluation t) in
        partial_evaluation form
end

let string_of_cnf = List.fold_left (fun str c -> str^(string_of_clause c)) ""
