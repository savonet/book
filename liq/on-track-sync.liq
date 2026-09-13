#!./liquidsoap
s = playlist("~/Music")
# header
s.on_track(synchronous=true,
           fun(m) -> log("New track: #{m['title']}"))
