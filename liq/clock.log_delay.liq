#!./liquidsoap
settings.clock.log_delay := 60.
s = sleeper(delay=2., delay_random=.1, sine())
output(s)
