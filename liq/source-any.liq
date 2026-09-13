#!./liquidsoap
# header
music = sine()
movie = video.testsrc()
sources = [(music : source(_)), (movie : source(_))]
print("we have #{list.length(sources)} sources")
