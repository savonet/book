#!/usr/bin/env liquidsoap
s = playlist("~/Music")
thread.run(delay=1., { print("Source s is up: #{s.is_up()}.") })
output(s)