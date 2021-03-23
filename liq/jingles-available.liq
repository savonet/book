#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = add([
    available(predicate.once({0m-10m or 30m-40m}), jingles),
    music
  ])
output(radio)
