#!/usr/bin/env liquidsoap
log.level := 5
low = sine(id="low", 440.)
hi  = sine(id="hi",  880.)
s   = switch(id="switch", track_sensitive=false,
      [({time() mod 4. <= 2.}, low), ({true}, hi)])
output(s)
