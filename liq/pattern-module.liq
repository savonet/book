#!./liquidsoap
# header
let v.{foo, bar} = "aabbcc".{foo = 123, bar = "baz"}
# v = "aabbcc", foo = 123, bar = 456
# footer
ignore(v)
ignore(foo)
ignore(bar)
