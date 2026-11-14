#!./liquidsoap
# Typechecks, but raises an uncaught error when run.
# header
myerr = error.register("my_error")
error.raise(myerr, "testing my own error")
