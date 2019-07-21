(** Pandoc extension to include files. *)

open Pandoc

let () =
  let json = Yojson.Basic.from_channel stdin in
  let rec f b =
    (* !include "file" *)
    try
      if not (is_paragraph b) then raise Exit;
      let p = Yojson.Basic.Util.to_list (block_contents b) in
      if List.length p < 3 then raise Exit;
      let i = List.hd p in
      if not (is_string i) || Yojson.Basic.Util.to_string (block_contents i) <> "!include" then raise Exit;
      let file = List.nth p 2 in
      if not (is_quoted file) then raise Exit;
      let file = Yojson.Basic.Util.to_list (block_contents file) in
      let file = Yojson.Basic.Util.to_list (List.nth file 1) in
      let file = List.hd file in
      if not (is_string file) then raise Exit;
      let file = block_contents file in
      let file = Yojson.Basic.Util.to_string file in
      let j = json_of_md_file file in
      List.flatten (List.map f (blocks j))
    with
    | Exit -> 
       (* ```include *)
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
