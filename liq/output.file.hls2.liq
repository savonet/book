#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("/tmp/hls")
aac_lofi  = %ffmpeg(format="mpegts",
                    %audio(codec="aac", channels=2, ar=44100))
aac_midfi = %ffmpeg(format="mpegts",
                    %audio(codec="aac", channels=2, ar=44100, b="96k"))
aac_hifi  = %ffmpeg(format="mpegts",
                    %audio(codec="aac", channels=2, ar=44100, b="192k"))
streams   = [("aac_lofi",  aac_lofi ), 
             ("aac_midfi", aac_midfi), 
             ("aac_hifi",  aac_hifi )]

def segment_name(~position, ~extname, stream_name) =
  timestamp = int_of_float(time())
  "#{stream_name}_#{timestamp}_#{position}.#{extname}"
end             

output.file.hls(playlist          = "live.m3u8",
                segment_duration  = 2.,
                segments          = 10,
                segments_overhead = 5,
                segment_name      = segment_name,
                persist_at        = "state.config",
                "/tmp/hls", streams, radio)
