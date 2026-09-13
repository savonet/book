#!/usr/bin/env liquidsoap
# header
def next()
  uri = list.hd(process.read.lines("./next-song"))
  request.create(uri)
end
s = request.dynamic(next)
# footer
output(s)
