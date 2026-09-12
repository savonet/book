#!./liquidsoap
config = '
name: My Radio
volume: 0.8
'
let yaml.parse (c : {name : string, volume : float}) = config
print("#{c.name} plays at volume #{c.volume}")
