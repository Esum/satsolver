module Env :
sig
    type t
    val is_empty : t -> bool
    val empty : t
    val singleton : int -> bool -> t
    val union : t -> t -> t
    val extend : t -> Intset.IntSet.t -> t
    val assoc : t -> int -> bool
    val funct : t -> int -> bool option
end

val print_env : Env.t -> unit
