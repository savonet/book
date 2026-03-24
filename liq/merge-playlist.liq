#!/usr/bin/env -S liquidsoap
infile  = argv(1)
outfile = argv(default="playlist.mp3", 2)
s       = playlist(mode="normal", loop=false, infile)
clock.assign_new(sync="none", [s])
o = output.file(fallible=true,
                %ffmpeg(format="mp3", %audio.copy), outfile, s)
o.on_stop(synchronous=false, shutdown)
