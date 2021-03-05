#!/usr/bin/env liquidsoap
s = playlist("~/Music")
def print_metadata(m)
  list.iter(fun (lv) -> print("- #{fst(lv)}: #{snd(lv)}"), m)
end
on_metadata(print_metadata, s)
output(s)
