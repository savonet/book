#!./liquidsoap
def tts_protocol(~rlog,~maxtime,arg) =
  ["process:wav,echo #{string.quote(arg)} | text2wave > $(output)"]
end
protocol.add(static=true,"tts",tts_protocol,
             doc="Generate speech synthesis.",
             syntax="tts:Text to read")

s = stereo(single("tts:Hello world!"))
output(s)
