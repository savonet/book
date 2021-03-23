#!./liquidsoap

# TODO: we seem to be getting the cover for the previous song...

s = mksafe(playlist("~/Music"))
coverfile = "/tmp/cover.jpg"
video = mksafe(mux_audio(audio=blank(), single(fallible=true, coverfile)))

def f(m)
  print("METADATA: #{m}")
  filename = list.assoc(default="", "filename", m)
  cover = file.cover(filename)
  if cover != "" then
    file.write(data=cover, coverfile)
  end
  video.skip()
end

s.on_metadata(f)

output.pulseaudio(s)
output.sdl(video)

def skip () =
  print("Skipping!")
  s.skip()
end
thread.run(every=2., skip)
