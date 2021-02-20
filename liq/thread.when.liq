#!/usr/bin/env liquidsoap
q    = request.queue()
song = {file.contents("song")}
thread.when(getter.changes(song), {q.push(request.create(song()))})
output(q)
