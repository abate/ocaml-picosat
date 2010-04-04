
open Printf
open Picosat

let drop str n =
  let l = String.length str in
  String.sub str n (l - n)

let take str n = String.sub str 0 n
let split str ch =
  let rec split' str l =
    try
      let i = String.index str ch in
      let t = take str i in
      let str' = drop str (i+1) in
      let l' = t::l in
      split' str' l'
    with Not_found ->
      List.rev (str::l)
  in
  split' str []

let process_file file =

  (* Mapping between variable names and indices. *)
  let vars = Hashtbl.create 0 in

  (* Processes a line containing a variable definition. *)
  let process_var line =
    let l = String.length line in
    assert (l > 2);
    assert (line.[1] = ' ');
    let name = drop line 2 in
    let v = Picosat.new_var () in
    Hashtbl.add vars name v
  in

  (* Processes a line containing a clause. *)
  let process_clause line =
    let l = String.length line in
    assert (l > 2);
    assert (line.[1] = ' ');
    let lits =
        List.map
          (fun lit ->
            if lit.[0] = '-' then
              (false, drop lit 1)
            else
              (true, lit)
          )
          (split (drop line 2) ' ')
    in
    let clause =
        List.map
          (fun (sign, name) ->
            let var = Hashtbl.find vars name in
            if sign then
              Picosat.pos_lit var
            else
              Picosat.neg_lit var
          )
          lits
    in
    Picosat.add_clause clause
  in

  (* Read a new line and processes its content. *)
  let rec process_line () =
    try
      let line = input_line file in
      if line = "" then
        ()
      else
        (match line.[0] with
        | 'v' -> process_var line
        | 'c' -> process_clause line
        | '#' -> ()
        | _   -> assert false
        );
      process_line ()
    with End_of_file ->
      ()
  in

  process_line ();
  vars

let solve file =
  Picosat.init ();
  Picosat.enable_trace ();
  let vars = process_file file in
  let revs =
    let acc = Hashtbl.create (Hashtbl.length vars) in
    Hashtbl.iter (fun name v -> Hashtbl.add acc v name) vars ;
    acc
  in
  match Picosat.solve () with
  | Picosat.UNKNOWN -> printf "Limit exausted\n"
  | Picosat.UNSAT ->
      begin
        printf "unsat\nunsat core : %s\n"
        (String.concat "," (List.map (fun i -> (Hashtbl.find revs i)) (Picosat.unsatcore ())))
      end
  | Picosat.SAT   ->
      begin
        printf "sat\nmodel : \n";
        List.iter (fun i ->
          printf "  %s=%s\n"
          (Hashtbl.find revs i)
          (Picosat.string_of_value (Picosat.value_of i))
        ) (Picosat.model ())
      end
;;

let main () =
  let argc = Array.length Sys.argv in
  if argc = 1 then
    solve stdin
  else
    Array.iter
      (fun fname ->
        try
          printf "Solving %s...\n" fname;
          solve (open_in fname)
        with Sys_error msg ->
          printf "ERROR: %s\n" msg
      )
      (Array.sub Sys.argv 1 (argc-1))

let () = main ()

