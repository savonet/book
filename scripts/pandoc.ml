open Yojson.Basic
open Util

(* http://hackage.haskell.org/package/pandoc-types-1.19/docs/Text-Pandoc-Definition.html *)

type format = string

(** Attributes: identifier, classes, key/values. *)
type attr = string * string list * (string * string) list

(** Target: url, title. *)
type target = string * string

(* type list_attributes = int * [`Decimal] * [`Period] *)

type math_type = [ `DisplayMath | `InlineMath ]

type quote_type = [ `DoubleQuote ]

type inline = [
  (* | `Code of attr * string *)
  (* | `Emph of inline list *)
  | `Image of attr * inline list * target
  | `Link of attr * inline list * target
  (* | `Math of math_type * string *)
  (* | `Note of block list *)
  | `Quoted of quote_type * inline list
  (* | `SoftBreak *)
  | `Space
  | `Str of string
  | `UnhandledInline of Yojson.Basic.t
  ]

and block = [
  (* | `BulletList of block list list *)
  | `CodeBlock of attr * string
  (* | `Header of int * attr * inline list *)
  (* | `OrderedList of list_attributes * block list list *)
  | `Para of inline list
  (* | `Plain of inline list *)
  | `RawBlock of format * string
  | `UnhandledBlock of Yojson.Basic.t
  ]

type t = { blocks : block list; api_version : int list; meta : Yojson.Basic.t }

module JSON = struct
  let element_type e =
    Util.to_string (List.assoc "t" (to_assoc e))

  let element_contents e =
    List.assoc "c" (to_assoc e)

  let to_pair p =
    match Util.to_list p with
    | [x; y] -> x, y
    | _ -> assert false

  let to_triple p =
    match Util.to_list p with
    | [x; y; z] -> x, y, z
    | _ -> assert false

  let to_attr attr =
    let id, classes, keyvals = to_triple attr in
    let id = Util.to_string id in
    let classes = List.map Util.to_string (Util.to_list classes) in
    let keyvals = List.map Util.to_list (Util.to_list keyvals) in
    let keyvals = List.map (function [k;v] -> (Util.to_string k, Util.to_string v) | _ -> assert false) keyvals in
    id, classes, keyvals

  let to_target t =
    let url, title = to_pair t in
    Util.to_string url, Util.to_string title

  let to_list_attributes a =
    let n, ns, nd = to_triple a in
    let n = Util.to_int n in
    let ns = element_type ns in
    let nd = element_type nd in
    (* TODO *)
    assert (ns = "Decimal");
    assert (nd = "Period");
    n, `Decimal, `Period

  let to_math_type t : math_type =
    match element_type t with
    | "DisplayMath" -> `DisplayMath
    | "InlineMath" -> `InlineMath
    | _ -> assert false

  let rec to_inline e =
    match element_type e with
    (* | "Code" -> *)
       (* let a, c = to_pair (element_contents e) in *)
       (* let a = to_attr a in *)
       (* let c = Util.to_string c in *)
       (* `Code (a, c) *)
    (* | "Emph" -> `Emph (List.map to_inline (Util.to_list (element_contents e))) *)
    | "Image" ->
       let a, i, t = to_triple (element_contents e) in
       let a = to_attr a in
       let i = List.map to_inline (Util.to_list i) in
       let t = to_target t in
       `Image (a, i, t)
    | "Link" ->
       let a, i, t = to_triple (element_contents e) in
       let a = to_attr a in
       let i = List.map to_inline (Util.to_list i) in
       let t = to_target t in
       `Link (a, i, t)
    (* | "Math" -> *)
       (* let t, m = to_pair (element_contents e) in *)
       (* let t = to_math_type t in *)
       (* let m = Util.to_string m in *)
       (* `Math (t, m) *)
    (* | "Note" -> `Note (List.map to_block (Util.to_list (element_contents e))) *)
    | "Quoted" ->
       let q, l = to_pair (element_contents e) in
       let q =
         match element_type q with
         | "DoubleQuote" -> `DoubleQuote
         | q -> failwith ("Unhandled quote type "^q)
       in
       let l = List.map to_inline (Util.to_list l) in
       `Quoted (q, l)
    (* | "SoftBreak" -> `SoftBreak *)
    | "Str" -> `Str (Util.to_string (element_contents e))
    | "Space" -> `Space
    | _ -> `UnhandledInline e
      
  and to_block e : block =
    match element_type e with
    (* | "BulletList" -> *)
       (* let l = Util.to_list (element_contents e) in *)
       (* let l = List.map (fun l -> List.map to_block (Util.to_list l)) l in *)
       (* `BulletList l *)
    | "CodeBlock" ->
       let attr, code = to_pair (element_contents e) in
       `CodeBlock (to_attr attr, Util.to_string code)
    (* | "Header" -> *)
       (* let n, a, t = to_triple (element_contents e) in *)
       (* let n = Util.to_int n in *)
       (* let a = to_attr a in *)
       (* let t = List.map to_inline (Util.to_list t) in *)
       (* `Header (n, a, t) *)
    (* | "OrderedList" -> *)
       (* let la, l = to_pair (element_contents e) in *)
       (* let la = to_list_attributes la in *)
       (* let l = Util.to_list l in *)
       (* let l = List.map (fun l -> List.map to_block (Util.to_list l)) l in *)
       (* `OrderedList (la, l) *)
    | "Para" -> `Para (List.map to_inline (Util.to_list (element_contents e)))
    (* | "Plain" -> `Plain (List.map to_inline (Util.to_list (element_contents e))) *)
    | "RawBlock" ->
       let fmt, contents = to_pair (element_contents e) in
       `RawBlock (Util.to_string fmt, Util.to_string contents)
    | _ -> `UnhandledBlock e

  let block t (c : Yojson.Basic.t) = `Assoc ["t", `String t; "c", c]

  let of_attr (id, classes, keyvals) =
    let id = `String id in
    let classes = `List (List.map (fun s -> `String s) classes) in
    let keyvals = `List (List.map (fun (k,v) -> `List [`String k; `String v]) keyvals) in
    `List [id; classes; keyvals]

  let of_target (url, title) =
    `List [`String url; `String title]

  let rec of_inline : inline -> 'a = function
    | `Image (a, i, t) ->
       block "Image" (`List [of_attr a; `List (List.map of_inline i); of_target t])
    | `Link (a, i, t) ->
       block "Link" (`List [of_attr a; `List (List.map of_inline i); of_target t])
    | `Quoted (q, l) ->
       let q =
         match q with
         | `DoubleQuote -> "DoubleQuote"
       in
       let l = List.map of_inline l in
       block "Quoted" (`List [`Assoc ["t", `String q]; `List l])
    | `Str s -> block "Str" (`String s)
    | `Space -> `Assoc ["t", `String "Space"]
    | `UnhandledInline b -> b

  let rec of_block : block -> 'a = function
    | `CodeBlock (a, s) -> block "CodeBlock" (`List [of_attr a; `String s])
    | `Para l -> block "Para" (`List (List.map of_inline l))
    | `RawBlock (f, c) -> block "RawBlock" (`List [`String f; `String c])
    | `UnhandledBlock b -> b
end

(** {2 Reading and writing} *)

let of_json json =
  let json = Util.to_assoc json in
  let blocks = Util.to_list (List.assoc "blocks" json) in
  let blocks = List.map JSON.to_block blocks in
  let api_version = List.assoc "pandoc-api-version" json in
  let api_version = List.map Util.to_int (Util.to_list api_version) in
  let meta = List.assoc "meta" json in
  { blocks; api_version; meta }

let to_json p =
  let blocks = `List (List.map JSON.of_block p.blocks) in
  let api_version = `List (List.map (fun n -> `Int n) p.api_version) in
  let meta = p.meta in
  `Assoc ["blocks", blocks; "pandoc-api-version", api_version; "meta", meta]

(** JSON from markdown file. *)
let json_of_md_file fname =
  let tmp = Filename.temp_file "pandoc" ".json" in
  let cmd = Printf.sprintf "pandoc -f markdown -t json %s -o %s" fname tmp in
  let n = Sys.command cmd in
  assert (n = 0);
  let json = from_file tmp in
  Sys.remove tmp;
  json

let of_md_file fname =
  let json = json_of_md_file fname in
  (* Printf.eprintf "%s\n%!" (Yojson.Basic.pretty_to_string json); *)
  of_json json

(*
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

*)

(** {2 Transforming} *)

(** Change the list of blocks. *)
let replace_blocks f p =
  { p with blocks = f p.blocks }

let map ?(block=(fun b -> None)) ?(inline=(fun i -> None)) p =
  let rec map_block (b : block) : block list =
    match block b with
    | Some bb -> bb
    | None ->
       match b with
       | `Para ii -> [`Para (map_inlines ii)]
       | b -> [b]
  and map_inline (i : inline) : inline list =
    match inline i with
    | Some ii -> ii
    | None ->
       match i with
       | `Image (a, i, t) -> [`Image (a, map_inlines i, t)]
       | `Link (a, i, t) -> [`Link (a, map_inlines i, t)]
       | `Quoted (q, i) -> [`Quoted (q, map_inlines i)]
       | i -> [i]
  and map_blocks bb = List.flatten (List.map map_block bb)
  and map_inlines ii : inline list = List.flatten (List.map map_inline ii) in
  replace_blocks map_blocks p

(** Map a function to every top-level block. *)
let map_top_blocks f p =
  replace_blocks (fun blocks -> List.flatten (List.map f blocks)) p

