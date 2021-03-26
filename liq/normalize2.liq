#!./liquidsoap
s = playlist("~/Music")
s = native.normalize(k_up=0.1, k_down=1., window=1., s)
thread.run(every=1., {log.important("Current gain: #{s.gain()}.")})
output(s)
