#!./liquidsoap
mode = ref("low")
output.dummy(sine())
# header
def add_filter() =
  output.dummy(filter.rc(mode=mode(), frequency=100., sine()))
end
server.register("filter", fun (m) -> begin mode := m; thread.run(add_filter); "OK" end)
