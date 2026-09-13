#!./liquidsoap
s = playlist("~/Music")
# header
s = lufs(s)
thread.run(every=1., {print("LUFS #{s.lufs()}")})
# footer
output(s)
