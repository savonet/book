#!./liquidsoap
files = file.ls(".")
files = list.filter(
          fun(x) -> string.match(pattern=".*\\.png|.*\\.jpg", x),
          files)
s     = image(list.hd(files))
thread.run(every=2., {s := list.pick(files)})
output.video(s)
