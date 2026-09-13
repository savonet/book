#!./liquidsoap
s = normalize(playlist("~/Music"))
# header
s = pipe(process="ffmpeg -i - -filter:a volume=1.5 -f wav -", s)
# footer
output(s)
