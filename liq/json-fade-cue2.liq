#!./liquidsoap
song = process.read("./next-song-json")
song = of_json(default=[("","")], song)
print("song: #{list.rev(song)}")