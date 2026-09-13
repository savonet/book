#!./liquidsoap
# header
let yaml.parse (conf : {playlist : string, volume : float}) =
  file.contents("radio.yaml")
s = amplify(conf.volume, playlist(conf.playlist))
# footer
output(s)
