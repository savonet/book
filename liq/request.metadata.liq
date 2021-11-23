#!./liquidsoap
filename = "test.mp3"
r = request.create(filename)
if request.resolve(r) then
  request.read_metadata(r)
  print("Metadata:")
  print(metadata.json.stringify(request.metadata(r)))
end
output.dummy(blank())