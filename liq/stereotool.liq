#!./liquidsoap
s = normalize(playlist("~/Music"))
# header
s = pipe(replay_delay=1.,
  process='/usr/bin/stereo_tool_cmd_64 - - -s myradio.sts -k "seckey"',
  s)
# footer
output(s)
