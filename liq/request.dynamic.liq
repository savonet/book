#!/usr/bin/env liquidsoap
def next()
  uri = list.hd(process.read.lines("./next-song"))
  request.create(uri)
end
s = request.dynamic(next)
output(s)
