module Clause:
sig
    type literal = int
    type t
    val empty : t
    val length : t -> int
    val check_length : int -> t -> bool
    val choose : t -> literal
    val map : (literal -> 'a) -> t -> 'a list
    val fold : ('a -> literal -> 'a) -> 'a -> t -> 'a
    val iter : (literal -> unit) -> t -> unit
    val for_all : (literal -> bool) -> t -> bool
    val exists : (literal -> bool) -> t -> bool
    val find : (literal -> bool) -> t -> int
    val filter : (literal -> bool) -> t -> t
    val mem : literal -> t -> bool
    val remove : literal -> t -> t
    val filter : (literal -> bool) -> t -> t
    val of_literal : literal -> t
    val of_list : literal list -> t
    val literals : t -> literal list
    val propositions : t -> int list
    val max_proposition : t -> int
end

val string_of_clause : Clause.t -> string

module Cnf :
sig
    type t
    val is_empty : t -> bool
    val choose : t -> Clause.t
    val add_clause : Clause.t -> t -> t
    val map : (Clause.t -> 'a) -> t -> 'a list
    val fold : ('a -> Clause.t -> 'a) -> 'a -> t -> 'a
    val iter : (Clause.t -> unit) -> t -> unit
    val for_all : (Clause.t -> bool) -> t -> bool
    val exists : (Clause.t -> bool) -> t -> bool
    val mem : Clause.literal -> t -> bool
    val remove : Clause.literal -> t -> t
    val find : (Clause.t -> bool) -> t -> Clause.t
    val find_some : (Clause.t -> bool) -> t -> Clause.t option
    val filter : (Clause.t -> bool) -> t -> t
    val filter_map : (Clause.t -> 'a option) -> t -> 'a list
    val of_list : Clause.t list -> t
    val literals : t -> Clause.literal list
    val max_proposition : t -> int
    val partial_evaluation : t -> (int -> bool option) -> t
end

val string_of_cnf : Cnf.t -> string
