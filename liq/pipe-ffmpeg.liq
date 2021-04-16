#!./liquidsoap
s = normalize(playlist("~/Music"))
s = pipe(process="ffmpeg -i - -filter:a volume=1.5 -f wav -", s)
output(s)
