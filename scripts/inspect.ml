(** Simple pandoc extension to print the JSON. *)

let () =
  let json = Yojson.Basic.from_channel stdin in
  let s = Yojson.Basic.pretty_to_string json in
  Printf.eprintf "%s\n%!" s;
  Printf.printf "%s\n%!" s

