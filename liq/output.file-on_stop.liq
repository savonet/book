#!./liquidsoap
radio = mksafe(playlist("~/Music"))
# header
o = output.file(%mp3, "out.mp3", radio)
o.on_stop(synchronous=false, {log.important("Recording is over.")})
