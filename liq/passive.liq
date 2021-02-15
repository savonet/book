s = input.http("http://...")
on_metadata(fun(m) -> print("New song: " ^ m["title"] ^ "\n"), s)
