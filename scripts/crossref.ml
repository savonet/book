(** Pandoc extension to have cross-references in LaTeX. Replaces links of the
   form #sec:blabla with a \cref{sec:blabla}. *)

open Yojson.Basic
open Pandoc

let begins_with prefix s =
  let l = String.length prefix in
  String.length s >= l
  && String.sub s 0 l = prefix

let () =
  let json = Yojson.Basic.from_channel stdin in
  let rec f b =
    try
      if try Util.to_string (List.assoc "t" b) <> "Link" with Not_found -> raise Exit then raise Exit;
      let l = Util.to_list (List.assoc "c" b) in
      if List.length l <> 3 then raise Exit;
      let l = Util.to_list (List.nth l 2) in
      let l = Util.to_string (List.hd l) in
      if not (begins_with "#chap:" l || begins_with "#sec:" l) then raise Exit;
      let l = String.sub l 1 (String.length l - 1) in
      Some (rawinline_tex (Printf.sprintf "\\cref{%s}" l))
    with
    | Exit -> None
  in
  let json = map_blocks f json in
  let s = Yojson.Basic.pretty_to_string json in
  Printf.printf "%s\n%!" s
