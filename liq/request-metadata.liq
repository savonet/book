#!./liquidsoap
# header
r = request.create("test.mp3")
print(request.metadata(r))
