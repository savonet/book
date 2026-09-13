#!./liquidsoap
# header
def next_song()
  answer = process.read("./next-song-json")
  let json.parse song = answer
  song = "annotate:\
          liq_cue_in=#{song.cue_in},liq_cue_out=#{song.cue_out},\
          liq_fade_in=#{song.fade_in},liq_fade_out=#{song.fade_out}:\
          #{song.file}"
  log.important("Next song is #{song}")
  request.create(song)
end
s = request.dynamic(next_song)
s = fade.out(fade.in(s))
output(s)
