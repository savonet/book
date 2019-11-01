#!./liquidsoap

# TODO: we seem to be getting the cover for the previous song...

s = mksafe(playlist("~/Music"))
coverfile = "/tmp/cover.jpg"
video = mksafe(single(fallible=true, coverfile))

def f(m)
  print("METADATA: #{m}")
  file = list.assoc(default="","filename",m)
  cover = file.cover(file)
  if cover != "" then
    ignore (file.write(data=cover, coverfile))
  end
  source.skip(video)
end

s = on_metadata(f,s)

output.pulseaudio(s)
output.sdl(video)

def skip () =
  print("Skipping!")
  source.skip(s)
  2.
end
add_timeout(2., skip)
