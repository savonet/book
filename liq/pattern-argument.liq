#!./liquidsoap
# header
# Destructure a labeled argument:
def f(~x:{gno}) =
  gno + 1
end
# f : (x : 'a.{gno : int}) -> int

# Destructure a list argument:
def f([a, b]) =
  a + b
end
# f : (['a]) -> 'a
# footer
ignore(f)
