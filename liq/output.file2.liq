#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.file(%mp3, "archive-%Y-%m-%d-%H-%M-%S.mp3", radio)
