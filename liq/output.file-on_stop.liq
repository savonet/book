#!./liquidsoap
radio = mksafe(playlist("~/Music"))
o = output.file(%mp3, "out.mp3", radio)
o.on_stop(synchronous=false, {log.important("Recording is over.")})
