#!./liquidsoap
# header
mode = environment.get("FILTER_MODE", default="low")
s =
  try
    filter.rc(mode=mode, frequency=100., playlist("~/Music"))
  catch err : [error.invalid] do
    log.important("Invalid filter: #{err.message}")
    playlist("~/Music")
  end
# footer
output(s)
