#!./liquidsoap
live_show = input.harbor("live")
music = playlist("~/Music")
relay = input.http("https://relay.example.com/stream")
relay.composition_type := "file"
radio = fallback([live_show, relay, music])
output(radio)
