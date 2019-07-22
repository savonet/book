open Yojson.Basic
open Util

type pandoc = Yojson.Basic.t
type block = t

(** {2 Reading of blocks} *)

(** Extract blocks from JSON. *)
let blocks j : block list =
  to_list (List.assoc "blocks" (to_assoc j))

let block_type (b : block) =
  Util.to_string (List.assoc "t" (to_assoc b))

let block_contents (b : block) =
  List.assoc "c" (to_assoc b)

let is_paragraph (b : block) = block_type b = "Para"

let is_string (b : block) = block_type b = "Str"

let to_string b =
  if not (is_string b) then raise Not_found;
  Util.to_string (block_contents b)

let is_space (b : block) = block_type b = "Space"

let is_quoted (b : block) = block_type b = "Quoted"

let is_code_block (b : block) =
  block_type b = "CodeBlock"

let to_code_block (b : block) =
  assert (is_code_block b);
  let c = block_contents b in
  let c = to_list c in
  let params, contents =
    match c with
    | [params; contents] -> params, Util.to_string contents
    | _ -> assert false
  in
  let ident, classes, keyvals =
    match to_list params with
    | [ident; classes; keyvals] ->
       Util.to_string ident,
       List.map Util.to_string (to_list classes),
       List.map (fun kv -> match to_list kv with [k; v] -> Util.to_string k, Util.to_string v | _ -> assert false) (to_list keyvals)
    | _ -> assert false
  in
  ((ident, classes, keyvals), contents)

let code_block_ident (b : block) =
  let ((ident, _, _), _) = to_code_block b in ident
  
let code_block_classes (b : block) =
  let ((_, classes, _), _) = to_code_block b in classes

let code_block_keyvals (b : block) =
  let ((_, _, keyvals), _) = to_code_block b in keyvals
                                              
let code_block_contents (b : block) =
  let (_, contents) = to_code_block b in contents

(** {2 Creation of blocks} *)

(** Create a block. *)
let block t c : block = `Assoc ["t", `String t; "c", c]

let paragraph l : block = block "Para" (`List l)

let string s : block = block "Str" (`String s)

let space : block = `Assoc ["t", `String "Space"]

let code_block ?(ident="") ?(classes=[]) ?(keyvals=[]) contents : block =
  let ident = `String ident in
  let classes = `List (List.map (fun c -> `String c) classes) in
  let keyvals = `List (List.map (fun (k,v) -> `List [`String k; `String v]) keyvals) in
  let contents = `String contents in
  block "CodeBlock" (`List [`List [ident; classes; keyvals]; contents])

let rawinline_tex s =
  block "RawInline" (`List [`String "tex"; `String s])

(** {2 Transforming} *)

(** Change the list of blocks. *)
let replace_blocks (f : block list -> block list) (j : pandoc) : pandoc
  =
  let blocks = blocks j in
  let blocks = `List (f blocks) in
  let j = List.remove_assoc "blocks" (to_assoc j) in
  let j = ("blocks",blocks)::j in
  `Assoc j

let rec map_assoc (f : (string*t) list -> t option) : t -> t = function
  | `List l -> `List (List.map (map_assoc f) l)
  | `Assoc a ->
     (
       match f a with
       | Some b -> b
       | None ->
          let a = List.map (fun (k,v) -> k, map_assoc f v) a in
          `Assoc a
     )
  | x -> x

(** Map a function to every block. *)
let map_blocks f j =
  replace_blocks
    (fun blocks ->
      List.map (fun b -> map_assoc f b) blocks
    ) j

(** Map a function to every top-level block. *)
let map_top_blocks f j =
  replace_blocks (fun blocks -> List.flatten (List.map f blocks)) j

(** {2 General utility functions} *)

(** JSON from markdown file. *)
let json_of_md_file f : pandoc =
  let tmp = Filename.temp_file "pandoc" ".json" in
  let cmd = Printf.sprintf "pandoc -f markdown -t json %s -o %s" f tmp in
  let n = Sys.command cmd in
  assert (n = 0);
  let j = from_file tmp in
  Sys.remove tmp;
  j
