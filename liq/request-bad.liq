#!./liquidsoap
r = request.create("inexistent.mp3")
print(request.resolve(r))
print(request.metadata(r))
