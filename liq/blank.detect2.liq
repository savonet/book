#!./liquidsoap
s = playlist("~/Music")
silent = ref(false)
s = blank.detect(on_noise={silent := false}, {silent := true}, s)
thread.run(every=1., {log.important("Source is silent: #{!silent}")})
output(s)
