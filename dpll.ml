open Intset
open Cnf
open Env

let rec evaluation form env = Cnf.for_all (Clause.exists (fun l -> try Env.assoc env l with _ -> false)) form

module DPLL =
struct

    let consistent_literals form =
        let contradicts s i = IntSet.mem (-i) s in
        match Cnf.for_all (Clause.check_length 1) form with
        | false -> false, Env.singleton 0 false
    	| true ->
            let s = IntSet.of_list (Cnf.map Clause.choose form) in
            match IntSet.exists (contradicts s) s  with
                | true -> false, Env.empty
                | false -> true, Env.extend Env.empty s

    let unit_propagation env form =
        let rec unit_propagation form env =
            let units = Cnf.filter_map (fun c -> match Clause.check_length 1 c with true -> Some (Clause.choose c) | false -> None) in
            match units form with
                | [] -> form, env
                | u ->
                    let new_env = Env.extend env (IntSet.of_list u) in
                    unit_propagation (Cnf.partial_evaluation form (Env.funct new_env)) new_env in
        unit_propagation form env

    let pure_literal_assign env form =
        let rec pure_literal_assign form env =
            let impures = ref IntSet.empty in
            let pures = ref IntSet.empty in
            let add_pures l = match IntSet.mem (abs l) (!impures) with
                | true -> ()
                | false -> match IntSet.mem (-l) (!pures) with
                        | false -> pures := IntSet.add l (!pures)
                        | true -> (
                            impures := IntSet.add (abs l) (!impures);
                            pures := IntSet.remove (-l) (!pures) ) in
            Cnf.iter (Clause.iter add_pures) form;
            match IntSet.is_empty (!pures) with
                | true -> form, env
                | false ->
                    let new_env = Env.extend env (!pures) in
                    pure_literal_assign (Cnf.partial_evaluation form (Env.funct new_env)) new_env in
        pure_literal_assign form env

    let dpll choice form =
        let rec dpll form env i =
            Printf.printf "%d " i; flush_all ();
            match consistent_literals form with
                | true, env' -> true, Env.union env env'
                | false, env when Env.is_empty env -> false, Env.empty
                | false, _ ->
            match Cnf.exists (Clause.check_length 0) form with
                | true -> false, Env.empty
                | false ->
            let form', env' = unit_propagation env form in
            let form'', env'' = pure_literal_assign env' form' in
            match choice form'' env'' with
            | 0 -> ( match Cnf.is_empty form'' with
                | true -> true, env''
                | _ -> false, Env.empty )
            | l ->
                let truth1, env1 = dpll (Cnf.add_clause (Clause.of_literal l) form'') env'' (i+1) in
                match truth1 with
                | true -> true, env1
                | false ->
                let truth2, env2 = dpll (Cnf.add_clause (Clause.of_literal (-l)) form'') env'' (i+1) in match truth2 with
                | true -> true, env2
                | false -> false, Env.empty in
        dpll form Env.empty 1

end


let argmax f c =
    let res = ref (Clause.choose c) in
    let value = ref (f (!res)) in
    Clause.iter (fun n -> match f n with
        | m when m > !value -> (res := n; value := m)
        | _ -> ()) c;
    !res

let choice_basic form env = try Clause.choose (Cnf.choose form) with _ -> 0

let choice_maxo form env =
    let occurences = Hashtbl.create 1000 in
    Cnf.iter (Clause.iter (fun l -> Hashtbl.replace occurences l (1+(try Hashtbl.find occurences l with _ -> 0)) )) form;
    let m = ref 0 in
    let l = ref 0 in
    Hashtbl.iter (fun lit occ -> match occ > !m with true -> (m := occ; l := lit) | false -> ()) occurences;
    !l


let dimacs str =
    let comment = Str.regexp "\\( *\\|\n*\\|\\)*c .*\n" in
    let header = Str.regexp "\\( *\\|\n*\\|\\)p +cnf +\\([0-9]+\\) +\\([0-9]+\\) *\n" in
    let literal = Str.regexp "\\( *\\|\n*\\|\\)\\(-?[0-9]+\\)\\( *\\|\n*\\|\\)" in
    let n = String.length str in
    let i = ref 0 in
    let form = ref [] in
    while !i < n-1 do
        if Str.string_match comment str (!i) then begin
            i := Str.match_end (); end
        else if Str.string_match header str (!i) then begin
            i := Str.match_end ();
            form := []::(!form) end
        else if Str.string_match literal str (!i) then begin
            i := Str.match_end ();
            let literal = int_of_string (Str.matched_group 2 str) in
            if literal = 0 then begin
                form := []::(!form) end
            else begin
                form := (literal::(List.hd (!form)))::(List.tl (!form));
            end end
        else begin
            i := n
        end
    done;
    Cnf.of_list (List.map (Clause.of_list) (List.tl (!form)))

let _ =
    let parse channel =
        let clauses = ref (-1) in
        let form = ref [] in
        let header = Str.regexp "p\\( \\|\t\\)+cnf\\( \\|\t\\)+\\([0-9]+\\)\\( \\|\t\\)+\\([0-9]+\\)\\( \\|\t\\)*" in
        let literal = Str.regexp "\\( \\|\t\\)*\\(-?[0-9]+\\)\\( \\|\t\\)*" in
        while !clauses = -1 do
            let line = input_line channel in
            if String.length line > 0 then
                if line.[0] = 'p' then
                    if Str.string_match header line 0 then begin
                        clauses := int_of_string (Str.matched_group 5 line);
                        form := []::(!form) end
        done;
        Printf.printf "Reading %d clauses...\n" (!clauses); flush_all ();
        let i = ref 0 in
        while !i < (!clauses) do
            if (!i) mod (1+(!clauses)/10) = 0 then Printf.printf "Reading clause %d/%d...\n" (!i+1) (!clauses); flush_all ();
            let line = input_line channel in
            let len = String.length line in
            let j = ref 0 in
            while !j < len do
                if Str.string_match literal line (!j) then begin
                    j := Str.match_end ();
                    let literal = int_of_string (Str.matched_group 2 line) in
                    if literal = 0 then begin
                        form := []::(!form);
                        incr i end
                    else begin
                        form := (literal::(List.hd (!form)))::(List.tl (!form));
                    end end
                else begin
                    Printf.eprintf "Malformed input.";
                    exit 1
                end
            done;
        done;
        Cnf.of_list (List.map (Clause.of_list) (List.tl (!form))) in
    let channel = match Array.length Sys.argv with
        | n when n > 1 -> open_in Sys.argv.(1)
        | _ -> stdin in
    let form = parse channel in
    close_in channel;
    print_string "Solving...\n"; flush_all ();
    match DPLL.dpll choice_maxo form with
        | false, _ -> print_string "false\n"
        | true, env ->
            print_string "true: ";
            print_env env; print_string "\n";
            match evaluation form env with
            | true -> print_string "OK.\n"
            | _ -> print_string "Something is wrong...\n"
