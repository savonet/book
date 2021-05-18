#!./liquidsoap
s = input.udp(host="localhost", port=8000, "application/ffmpeg")
output(s)
