
type var = int
type lit
type value = True | False | Unknown
type solution = SAT | UNSAT | UNKNOWN

val init : ?seed : int -> ?nvars : int -> ?trace : bool -> unit -> unit
external reset: unit -> unit = "caml_picosat_reset"

external model: unit -> var list = "caml_model"
external unsatcore : unit -> var list = "caml_unsatcore"

val add_clause : lit list -> unit

val solve : ?limit : int -> unit -> solution 
val solve_with_assumptions : ?limit : int  -> lit list -> solution 

val new_var : unit -> var
val value_of : var -> value

val pos_lit : var -> lit
val neg_lit : var -> lit

val string_of_value : value -> string
