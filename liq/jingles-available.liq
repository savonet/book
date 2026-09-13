#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = add([
    source.available(jingles, predicate.once({0m-10m or 30m-40m})),
    music
  ])
# footer
output(radio)
