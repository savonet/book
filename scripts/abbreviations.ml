(** Abbreviations to be followed by non-breakable space. Pandoc already does
   that but it does not play well with other plugins such as include, and
   abbreviations followed by code are not handled. *)

open Yojson.Basic
open Pandoc

let abbreviations =
  let fname = "abbreviations" in
  let ic = open_in fname in
  let n = in_channel_length ic in
  let s = Bytes.create n in
  really_input ic s 0 n;
  close_in ic;
  let s = Bytes.unsafe_to_string s in
  let l = String.split_on_char '\n' s in
  let l = List.filter (fun s -> s <> "") l in
  List.append l (List.map (fun s -> "(" ^ s) l)

let () =
  let p = Pandoc.of_json (Yojson.Basic.from_channel stdin) in
  let rec f = function
    | (Str s)::Space::ii when List.mem s abbreviations -> Str (s^" ")::(f ii)
    | i::ii -> i::(f ii)
    | [] -> []
  in
  let p = Pandoc.map_inlines f p in
  let s = Yojson.Basic.pretty_to_string (Pandoc.to_json p) in
  Printf.printf "%s\n%!" s
