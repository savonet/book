#!./liquidsoap
s = playlist("~/Music")
s = lufs(s)
thread.run(every=1., {print("LUFS #{s.lufs()}")})
output(s)
