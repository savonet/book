#!./liquidsoap
# header
r/(foo)(?<gno>gni)?/g.exec("foogni")
# Returns: [(2, "gni"), (1, "foo"), (0, "foogni")].{groups = [("gno", "gni")]}
