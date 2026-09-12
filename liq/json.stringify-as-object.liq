#!/usr/bin/env liquidsoap
data = [("f", 1), ("b", 4)]
j = json.object()
list.iter(fun ((k, v)) -> j.add(k, v), data)
print(j.stringify())
