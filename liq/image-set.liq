#!./liquidsoap
files = file.ls(".")
files = list.filter(
          fun(x) -> string.match(pattern=".*\\.png|.*\\.jpg", x),
          files)
img_path = ref(list.hd(files))
s     = image(img_path)
thread.run(every=2., {img_path := list.pick(files)})
output.video(s)
