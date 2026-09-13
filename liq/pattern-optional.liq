#!./liquidsoap
# header
let {foo?} = ()
# foo = null

let {foo?} = {foo = 123}
# foo = 123
# footer
ignore(foo)
