#!/usr/bin/env liquidsoap
night = sine()
day = sine()
radio = switch( [ ({0h-7h}, night), ({7h-24h}, day) ] )
out(radio)