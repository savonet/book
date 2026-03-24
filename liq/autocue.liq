#!./liquidsoap
enable_autocue_metadata()
s = playlist("~/Music")
s = crossfade(s)
output.icecast(%mp3, host="localhost", port=8000, password="hackme",
                     mount="radio", s)
