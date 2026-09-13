#!./liquidsoap
# header
jingles = rotate([
    playlist("jingles"),
    playlist("commercials"),
    playlist("announcements")
  ])
# footer
output(jingles)
