#!/usr/bin/env -S liquidsoap
infile  = argv(1)
outfile = argv(default="playlist.mp3", 2)
s       = playlist(mode="normal", loop=false, infile)
s       = clock(sync="none", s)
output.file(fallible=true, on_stop=shutdown,
            %ffmpeg(format="mp3", %audio.copy), outfile, s)
