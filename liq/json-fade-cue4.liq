#!./liquidsoap
song = process.read("./next-song-json")
default = {file="", cue_in=0., cue_out=0., fade_in=0., fade_out=0.}
song = of_json(default=default, song)
print("song: #{song}")