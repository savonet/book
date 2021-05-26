#!./liquidsoap
s = input.http("https://icecast.radiofrance.fr/fip-hifi.aac")
output(s)
