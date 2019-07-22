stream = input.http("http://...")
emergency = playlist("~/Music")
s = fallback([stream, emergency])
out(s)