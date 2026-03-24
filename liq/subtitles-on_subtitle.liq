#!./liquidsoap
s = playlist("~/Music")
s = on_subtitle(fun (sub) ->
      print("Subtitle at #{sub.absolute_start_time}s: #{sub.text}"), s)
output(s)
