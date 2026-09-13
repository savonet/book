#!./liquidsoap
s = playlist("~/Music")
# header
s.on_position(synchronous=true, remaining=true, position=30.,
              fun(_, m) -> log("30 seconds left in: #{m['title']}")
)
