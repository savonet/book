#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.file(%mp3, {time.string("archive/%Y-%m-%d/%H-%M-%S.mp3")}, radio)
