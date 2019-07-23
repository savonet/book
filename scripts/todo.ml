(** Convert !TODO bla bla into \TODO{bla bla}. *)

open Yojson.Basic

let begins_with prefix s =
  let l = String.length prefix in
  String.length s >= l
  && String.sub s 0 l = prefix

let () =
  let p = Pandoc.of_json (Yojson.Basic.from_channel stdin) in
  let rec f = function
    | Pandoc.Para ((Str t)::l) when t = "!TODO" || t = "!TODO:" ->
       let l = if List.length l > 0 && List.hd l = Space then List.tl l else l in
       let l =
         List.map
           (function
            | Pandoc.Space -> " " 
            | Str s -> s
            | Code (a, c) ->
               let c = Str.global_replace (Str.regexp "_") "\\_" c in
               Printf.sprintf "\\texttt{%s}" c
            | Link (a, i, t) -> "<link>"
            | _ -> "*****"
           ) l
       in
       let l = String.concat "" l in
       [Pandoc.Para [RawInline ("tex", Printf.sprintf "\\TODO{%s}" l)]]
    | b -> [b]
  in
  let p = Pandoc.map_top_blocks f p in
  let s = Yojson.Basic.pretty_to_string (Pandoc.to_json p) in
  Printf.printf "%s\n%!" s
