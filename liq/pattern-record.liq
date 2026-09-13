#!./liquidsoap
# header
let {foo, bar} = {foo = 123, bar = "baz", gni = true}
# foo = 123, bar = "baz"

let {foo, bar, ...x} = {foo = 123, bar = "baz", gni = true}
# foo = 123, bar = "baz", x = {gni = true}
# footer
ignore(foo)
ignore(bar)
ignore(x)
