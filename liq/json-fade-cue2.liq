#!./liquidsoap
song = process.read("./next-song-json")
song = json.parse(default=[("","")], song)
print("song: #{list.rev(song)}")