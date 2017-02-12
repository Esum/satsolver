open Intset

module Env =
struct

    module E = Map.Make(
        struct
            let compare = Pervasives.compare
            type t = int
        end )

    type t = bool E.t

    let is_empty = E.is_empty

    let empty = E.empty

    let singleton = E.singleton

    let union = E.union (fun p v v' -> Some v)

    let extend env news = match IntSet.is_empty news with
        | true -> env
        | false -> IntSet.fold (fun l e -> E.add (abs l) (l > 0) e) news env

    let assoc env l = match l > 0, abs l with
        | true, p -> E.find p env
        | false, p -> not (E.find p env)

    let funct env = fun l -> try  Some (assoc env l) with Not_found -> None

end

let print_env env =
    let rec print_env = function
        | (p, v)::t -> (Printf.printf "%d=%B; " p v; print_env t)
        | _ -> () in
    print_env (Env.E.bindings env)
