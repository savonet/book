#!/usr/bin/env liquidsoap
def next()
  uri = process.read.lines("./next-song")
  uri = list.hd(uri)
  request.create(uri)
end
s = request.dynamic(next)
out(s)