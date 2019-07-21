(** Pandoc extension to include files. *)

open Pandoc

let () =
  let json = Yojson.Basic.from_channel stdin in
  let rec f b =
    if is_code_block b && List.mem "include" (code_block_classes b) then
      let contents = code_block_contents b in
      let j = json_of_md_file contents in
      List.flatten (List.map f (blocks j))
    else
      [b]
  in
  let json = map_top_blocks f json in
  let s = Yojson.Basic.pretty_to_string json in
  Printf.printf "%s\n%!" s
