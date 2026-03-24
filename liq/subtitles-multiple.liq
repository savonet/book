#!./liquidsoap
s = input.ffmpeg("movie.mkv")
let {audio, video} = source.tracks(s)
let {subtitles = english} = source.tracks(single("english.srt"))
let {subtitles = french}  = source.tracks(single("french.srt"))
s = source({audio=audio, video=video, subtitles=english, subtitles_2=french})
output.dummy(s)
