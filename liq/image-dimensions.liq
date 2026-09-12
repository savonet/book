#!./liquidsoap
s = image(x=10, y=10, width=50, height=50, "test.png")
output.video(fallible=true, s)
