#!./liquidsoap
radio = mksafe(playlist("~/Music")) radio = source.run(radio, every=2., {radio.skip()})
filename = ref("archive/default.mp3")
def handle_metadata(m)
  filename := "archive/#{m['artist']} - #{m['title']}.mp3"
  true
end
f = output.file(%mp3, filename, radio,
                reopen_on_metadata=handle_metadata)
