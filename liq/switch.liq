#!/usr/bin/env liquidsoap
night = sine()
day   = sine()
# header
radio = switch( [ ({0h-7h}, night), ({7h-24h}, day) ] )
# footer
output(radio)
