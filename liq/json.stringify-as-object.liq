#!/usr/bin/env liquidsoap
# header
data = [("f", 1), ("b", 4)]
j = json.object()
list.iter(fun ((k, v)) -> j.add(k, v), data)
# footer
print(j.stringify())
