#!./liquidsoap
# header
# Adds 1 to x, or options.add if that field is present
def f(x, options) =
  x + (options.add ?? 1)
end
# footer
ignore(f)
