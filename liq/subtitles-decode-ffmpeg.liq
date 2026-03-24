#!./liquidsoap
let {audio, video, subtitles} = source.tracks(input.ffmpeg("movie.mkv"))
