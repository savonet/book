#!./liquidsoap
log.level.set(5)
s = input.http("https://icecast.radiofrance.fr/fip-hifi.aac?id=liq")
output(s)
