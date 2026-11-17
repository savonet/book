#!./liquidsoap
def add_filter() =
  ()
end
# header
thread.run(
  on_error=fun (err) -> log.important("Could not add the filter: #{error.methods(err).kind}"),
  add_filter
)
