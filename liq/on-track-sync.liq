#!./liquidsoap
s = playlist("~/Music")
s.on_track(synchronous=true,
           fun(m) -> log("New track: #{m['title']}"))
