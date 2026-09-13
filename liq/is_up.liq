#!/usr/bin/env liquidsoap
# header
s = playlist("~/Music")
thread.run(delay=1., { print("Source s is up: #{s.is_up()}.") })
# footer
output(s)
