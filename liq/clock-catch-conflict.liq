#!./liquidsoap
# header
# Two sources, each already streaming through its own output, so each runs in
# its own clock.
a = sine()
output.dummy(a)
b = sine()
output.dummy(b)

# Called later, for instance from a server command: they cannot be combined.
def combine() =
  try
    output.dummy(fallible=true, switch([({true}, a), ({true}, b)]))
  catch err : [error.clock] do
    log.important("Could not combine the sources: #{err.message}")
  end
end
server.register("combine", fun (_) -> begin combine(); "OK" end)
