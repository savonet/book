#!./liquidsoap
s = mksafe(playlist("~/Music"))
# header
radio_hls =
  output.file.hls(
    prefix="https://cdn.example.com/radio",
    "/var/www/hls",
    [("mp3", %mp3(bitrate=128))],
    s
  )

def ad_break(_) =
  radio_hls.insert_tag("#EXT-X-CUE-OUT:30")
  "Ad break announced."
end
server.register("ad_break", ad_break)
