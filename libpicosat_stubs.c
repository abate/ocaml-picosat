/**************************************************************************************/
/*  Copyright (C) 2009 Pietro Abate <pietro.abate@pps.jussieu.fr>                     */
/*                                                                                    */
/*  This library is free software: you can redistribute it and/or modify              */
/*  it under the terms of the GNU Lesser General Public License as                    */
/*  published by the Free Software Foundation, either version 3 of the                */
/*  License, or (at your option) any later version.  A special linking                */
/*  exception to the GNU Lesser General Public License applies to this                */
/*  library, see the COPYING file for more information.                               */
/**************************************************************************************/


#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <picosat/picosat.h>

#define Val_none Val_int(0)

static inline value Val_some( value v )
{
  CAMLparam1( v );
  CAMLlocal1( some );
  some = caml_alloc(1, 0);
  Store_field( some, 0, v );
  CAMLreturn(some);
}

static inline value tuple( value a, value b) {
  CAMLparam2( a, b );
  CAMLlocal1( tuple );

  tuple = caml_alloc(2, 0);

  Store_field( tuple, 0, a );
  Store_field( tuple, 1, b );

  CAMLreturn(tuple);
}

static inline value append( value hd, value tl ) {
  CAMLparam2( hd , tl );
  CAMLreturn(tuple( hd, tl ));
}

CAMLprim value caml_picosat_init(value unit) {
  CAMLparam0 ();
  picosat_init();
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_reset(value unit) {
  CAMLparam0 ();
  picosat_reset();
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_set_seed(value seed) {
  CAMLparam1 (seed);
  picosat_set_seed(Unsigned_int_val(seed));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_enable_trace(value unit) {
  CAMLparam0 ();
  picosat_enable_trace_generation();
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_add(value lit) {
  CAMLparam1 (lit);
  picosat_add(Int_val(lit));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_assume(value lit) {
  CAMLparam1 (lit);
  picosat_assume(Int_val(lit));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_picosat_deref(value lit) {
  CAMLparam1 (lit);
  CAMLreturn(Val_int(picosat_deref(Int_val(lit))));
}

CAMLprim value caml_picosat_usedlit(value lit) {
  CAMLparam1 (lit);
  CAMLreturn(Val_int(picosat_usedlit(Int_val(lit))));
}

CAMLprim value caml_picosat_corelit(value lit) {
  CAMLparam1 (lit);
  CAMLreturn(Val_int(picosat_corelit(Int_val(lit))));
}

CAMLprim value caml_unsatcore(value unit) {
  CAMLparam0 ();
  CAMLlocal1( tl );
  tl = Val_emptylist;
  int i, max_idx = picosat_variables ();
  for (i = 1; i <= max_idx; i++)
    /* discard all variables that are not in the unsat core */
    if (picosat_corelit (i))
      tl = append (Val_int(i), tl);

  CAMLreturn(tl);
}

CAMLprim value caml_model(value unit) {
  CAMLparam0 ();
  CAMLlocal1( tl );
  tl = Val_emptylist;
  int i, max_idx = picosat_variables ();
  for (i = 1; i <= max_idx; i++)
    /* discard all variables that are unknown */
    if (picosat_deref (i)) 
      tl = append (Val_int(i), tl);

  CAMLreturn(tl);
}

CAMLprim value caml_picosat_sat(value limit) {
  CAMLparam1 (limit);
  CAMLlocal1( res );
  switch (picosat_sat(Int_val(limit))) {
    case PICOSAT_UNSATISFIABLE : res = Val_int(-1) ; break ;
    case PICOSAT_SATISFIABLE : res = Val_int(1) ; break ;
    case PICOSAT_UNKNOWN : res = Val_int(0) ; break ;
  }
  CAMLreturn(res);
}

/*
void picosat_set_output (FILE *);
void picosat_set_verbosity (int new_verbosity_level);
*/
