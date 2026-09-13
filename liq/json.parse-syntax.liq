#!./liquidsoap
json = '{"file": "test.mp3"}'
# header
let json.parse x = json
# footer
ignore(x)
