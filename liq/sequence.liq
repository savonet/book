#!./liquidsoap
s1 = single("jingle1.mp3")
s2 = single("jingle2.mp3")
s3 = playlist("~/Music")
# header
s = sequence([s1, s2, s3])
# footer
output(mksafe(s))
