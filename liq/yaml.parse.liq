#!./liquidsoap
# header
let yaml.parse (config : {name : string, volume : float}) =
  file.contents("config.yaml")
print("#{config.name} plays at volume #{config.volume}")
