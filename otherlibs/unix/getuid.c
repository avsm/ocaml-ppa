/***********************************************************************/
/*                                                                     */
/*                           Objective Caml                            */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../../LICENSE.  */
/*                                                                     */
/***********************************************************************/

/* $Id: getuid.c,v 1.8.6.1 2005/01/17 18:10:36 doligez Exp $ */

#include <mlvalues.h>
#include "unixsupport.h"

CAMLprim value unix_getuid(value unit)
{
  return Val_int(getuid());
}
