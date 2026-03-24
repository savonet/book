#!./liquidsoap
s = playlist("~/Music")
s = subtitles.insert(s)
thread.run(delay=1., {
  s.insert_subtitle({
    duration = 5.0,
    text     = "Hello, world!",
    format   = "text",
    forced   = false
  })
})
output(s)
