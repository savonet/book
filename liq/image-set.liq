#!./liquidsoap
files = file.ls(".")
files = list.filter(string.match(pattern=".*\\.png|.*\\.jpg"), files)
s     = image(list.hd(files))
thread.run(every=2., {s := list.pick(files)})
output.video((s:source(audio=none)))
