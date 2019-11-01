#!/usr/bin/env liquidsoap
def next()
  uri = get_process_lines("./next-song")
  uri = list.hd(default="", uri)
  request.create(uri)
end
s = request.dynamic(next)
out(s)