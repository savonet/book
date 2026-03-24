#!./liquidsoap
s = single("movie.mkv")
s = subtitles.map(fun (sub) ->
  if sub.text == "" then null
  else {text = string.uppercase(sub.text)}
  end, s)
output(s)
