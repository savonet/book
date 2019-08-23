#!/usr/bin/env liquidsoap
def text2wave_protocol(~rlog,~maxtime,arg) =
  ["process:wav,echo #{string.quote(arg)} | text2wave > $(output)"]
end
add_protocol(static=true,"text2wave",text2wave_protocol,
             doc="Generate speech synthesis.",
             syntax="text2wav:Text to read")

s = audio_to_stereo(single("text2wave:Hello world!"))
out(s)
