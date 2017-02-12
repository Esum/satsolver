module Env :
sig
    type t
    (** [is_empty env] returns true iff [env] has no variable set*)
    val is_empty : t -> bool
    (** [empty ()] returns an empty Env.t *)
    val empty : t
    (** [singleton n b] returns an Env.t which match the variable n to the value b *)
    val singleton : int -> bool -> t
    (** [union e e'] returns a new Env.t which is the union of [e] and [e'] *)
    val union : t -> t -> t
    (** [extent env s] returns a new Env.t obtained by setting to true the literals of [s] in [env] *)
    val extend : t -> Intset.IntSet.t -> t
    (** [assoc env p] returns the value of the proposition [p] in [env], raises Not_found if [p] has no value *)
    val assoc : t -> int -> bool
    (** [funct env p] returns the value of the proposition [p] in [env] or None if [p] has no value*)
    val funct : t -> int -> bool option
end

(** [print_env env] prints the Env.t [env] on stdout *)
val print_env : Env.t -> unit
