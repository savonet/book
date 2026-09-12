#!./liquidsoap
music = playlist("~/Music")
q = request.queue(id="q")
radio = fallback([q, music])
cron.add("0 * * * *", {q.push.uri("jingles/top-of-the-hour.mp3")})
output(radio)
