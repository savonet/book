#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = switch([
  (predicate.once({0m-10m or 30m-40m}), jingles),
  ({true}, music)
])
output(radio)
