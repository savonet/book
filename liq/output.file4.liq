#!./liquidsoap
radio = mksafe(playlist("~/Music")) radio = source.run(radio, every=2., {radio.skip()})
filename = ref("archive/default.mp3")
f = output.file(%mp3, filename, radio)
def handle_metadata(m)
  filename := "archive/#{m['artist']} - #{m['title']}.mp3"
  f.reopen()
end
radio.on_metadata(handle_metadata)
