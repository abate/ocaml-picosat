
type var = int
type lit = Neg of int | Pos of int
type value = True | False | Unknown
type solution = SAT | UNSAT | UNKNOWN

(* in picosat there are only literals that can be positive
 * or negative, whether gt or lt zero *)

external __init: unit -> unit = "caml_picosat_init"
external reset: unit -> unit = "caml_picosat_reset"
external adjust : int -> unit = "caml_picosat_adjust"

external set_seed: int -> unit = "caml_picosat_set_seed"
external enable_trace: unit -> unit = "caml_picosat_enable_trace"

external __add: int -> unit = "caml_picosat_add"

external __assume: int -> unit = "caml_picosat_assume"

external sat: int -> int = "caml_picosat_sat"

external deref: int -> int = "caml_picosat_deref"

external usedlit: int -> int = "caml_picosat_usedlit"
external corelit: int -> int = "caml_picosat_corelit"

external model: unit -> int list = "caml_model"
external unsatcore : unit -> int list = "caml_unsatcore"

let varcount = ref 0
(* never returns 0 that means end of clause *)
let new_var () = incr varcount ; !varcount ;;

let init ?(trace=false) ?nvars () =
  begin match nvars with
  |None -> __init ()
  |Some n -> __init () ; adjust n end;
  if trace then enable_trace ()

let of_lit = function
  |Neg i when i <> 0 -> -i
  |Pos i when i <> 0 -> i
  |_ -> assert false

let to_value = function
  |  1 -> True
  |  0 -> Unknown
  | -1 -> False
  |  _ -> assert false

let to_solution = function
  | -1 -> UNSAT
  |  0 -> UNKNOWN
  |  1 -> SAT
  |  _ -> assert false

let value_of v = to_value (deref v)
let assume lit = __assume (of_lit lit)
let add lit = __add (of_lit lit)
let add_clause l = List.iter add l ; __add 0 ;;

let solve ?(limit=1000) () = to_solution (sat limit)
let solve_with_assumptions ?(limit=1000) l = List.iter assume l; to_solution (sat limit) ;;

let pos_lit v = Pos v
let neg_lit v = Neg v

let string_of_value = function
  |False -> "false"
  |True -> "true"
  |Unknown -> "unknown"

