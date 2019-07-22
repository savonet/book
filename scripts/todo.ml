(** Convert !TODO bla bla into \TODO{bla bla}. *)

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
      if try Util.to_string (List.assoc "t" b) <> "Para" with Not_found -> raise Exit then raise Exit;
      let l = Util.to_list (List.assoc "c" b) in
      if List.length l < 1 then raise Exit;
      let todo = List.hd l in
      let todo = try to_string todo with Not_found -> raise Exit in
      if todo <> "!TODO" && todo <> "!TODO:" then raise Exit;
      let l = List.tl l in
      let l = if List.length l > 0 && is_space (List.hd l) then List.tl l else l in
      let l =
        List.map
          (fun b ->
            match block_type b with
            | "Space" -> " "
            | "Str" -> to_string b
            | "Code" ->
               let c = Util.to_string (List.nth (Util.to_list (block_contents b)) 1) in
               let c = Str.global_replace (Str.regexp "_") "\\_" c in
               Printf.sprintf "\\texttt{%s}" c
            | "Link" ->
               let l = Util.to_list (block_contents b) in
               let l = List.hd (Util.to_list (List.nth l 1)) in
               to_string l
            | _ -> Printf.sprintf "\\verb|%s|" (Yojson.Basic.to_string b)
          ) l
      in
      let l = String.concat "" l in
      Some (paragraph [rawinline_tex (Printf.sprintf "\\TODO{%s}" l)])
    with
    | Exit -> None
  in
  let json = map_blocks f json in
  let s = Yojson.Basic.pretty_to_string json in
  Printf.printf "%s\n%!" s
