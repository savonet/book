#!./liquidsoap
jingles = rotate([
    playlist("jingles"),
    playlist("commercials"),
    playlist("announcements")
  ])
output(jingles)
