#!./liquidsoap
song = process.read("./next-song-json")
song = of_json(default=[("",0.)], song)
print("song: #{song}")