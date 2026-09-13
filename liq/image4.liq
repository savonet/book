#!./liquidsoap
# header
s = image("annotate:width=50,height=50:test.png")
output.video(fallible=true, s)
