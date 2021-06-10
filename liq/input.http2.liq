#!./liquidsoap
s = buffer(input.http("https://icecast.radiofrance.fr/fip-hifi.aac"))
output(s)
