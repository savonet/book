#!./liquidsoap
s = playlist("~/Music")
silent = ref(false)
s = blank.detect(s)
s.on_blank(synchronous=false, {silent := true})
s.on_noise(synchronous=false, {silent := false})
thread.run(every=1., {log.important("Source is silent: #{silent()}")})
output(s)
