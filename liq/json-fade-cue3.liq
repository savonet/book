#!./liquidsoap
song = process.read("./next-song-json")
song = json.parse(default=[("",0.)], song)
print("song: #{song}")