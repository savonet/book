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
       (* ```{.blabla include="file"}
          ``` *)
       if is_code_block b && List.mem_assoc "include" (code_block_keyvals b) then
         let keyvals = code_block_keyvals b in
         let contents =
           let fname = List.assoc "include" keyvals in
           try
             let from = try int_of_string (List.assoc "from" keyvals) with Not_found -> 0 in
             let ic = open_in fname in
             let ans = ref "" in
             let line = ref 0 in
             try
               while true do
                 if !line >= from then ans := !ans ^ input_line ic ^ "\n";
                 incr line
               done;
               ""
             with
             | End_of_file -> !ans
           with
           | Sys_error _ -> "*** ERROR: file \""^fname^"\" not found! ***"
         in
         let b = code_block ~ident:(code_block_ident b) ~classes:(code_block_classes b) ~keyvals contents in
         [b]
       else
         [b]
  in
  let json = map_top_blocks f json in
  let s = Yojson.Basic.pretty_to_string json in
  Printf.printf "%s\n%!" s
