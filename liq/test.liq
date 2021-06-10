#!./liquidsoap
log.level.set(5)
s = buffer(input.http("https://icecast.radiofrance.fr/fip-hifi.aac?id=liq"))
output(s)
