#!./liquidsoap
set("decoder.priorities.mad", 15) #1546
def next_song()
  song     = process.read("./next-song-json")
  default  = {file="", cue_in=0., cue_out=0., fade_in=0., fade_out=0.}
  song     = json.parse(default=default, song)
  print(string_of(fields=true, song))
  song = "annotate:\
          liq_cue_in=#{song.cue_in},liq_cue_out=#{song.cue_out},\
          liq_fade_in=#{song.fade_in},liq_fade_out=#{song.fade_out}:\
          #{song.file}"
  log.important("Next song is #{song}")
  request.create(song)
end
s = request.dynamic(next_song)
s = fade.out(fade.in(cue_cut(s)))
output(s)