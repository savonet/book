#!./liquidsoap
# header
# Using the regexp operator:
r = regexp(flags=["g", "i"], "foo([\\w])+bar")

# Using the r/../ syntactic sugar:
r = r/foo([\w])bar/gi
# footer
ignore(r)
