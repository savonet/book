#!./liquidsoap
radio = mksafe(playlist("~/Music"))
o = output.file.hls("/tmp/hls", [("mp3", %mp3)], radio)
# header
def on_file_change(segment)
  if segment.state == "created" then
    print("The file #{segment.path} was created.")
  elsif segment.state == "deleted" then
    print("The file #{segment.path} was deleted.")
  end
end
o.on_file_change(synchronous=false, on_file_change)
