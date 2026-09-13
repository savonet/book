#!./liquidsoap
# header
let {subtitles = part1} = source.tracks(single("part1.srt"))
let {subtitles = part2} = source.tracks(single("part2.srt"))
s = sequence([source({subtitles=part1}), source({subtitles=part2})])
# footer
output.dummy(fallible=true, s)
