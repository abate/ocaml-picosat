
type var
type lit
type value = True | False | Unknown
type solution = SAT | UNSAT | UNKNOWN

external init: unit -> unit = "caml_picosat_init"
external reset: unit -> unit = "caml_picosat_reset"

external set_seed: int -> unit = "caml_picosat_set_seed"
external enable_trace: unit -> unit = "caml_picosat_enable_trace"

val add_clause : lit list -> unit

val solve : ?limit : int -> unit -> solution 
val solve_with_assumptions : ?limit : int  -> lit list -> solution 

val model : unit -> var list
val unsatcore : unit -> var list

val new_var : unit -> var
val value_of : var -> value

val pos_lit : var -> lit
val neg_lit : var -> lit
