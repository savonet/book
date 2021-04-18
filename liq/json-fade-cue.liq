#!./liquidsoap
set("decoder.priorities.mad", 15) #1546
def next_song()
  song     = process.read("./next-song-json")
  song     = of_json(default=[("","")], song)
  file     = song["file"]
  cue_in   = song["cue_in"]
  cue_out  = song["cue_out"]
  fade_in  = song["fade_in"]
  fade_out = song["fade_out"]
  song = "annotate:liq_cue_in=#{cue_in},liq_cue_out=#{cue_out},\
          liq_fade_in=#{fade_in},liq_fade_out=#{fade_out}:#{file}"
  log.important("Next song is #{song}")
  request.create(song)
end
s = request.dynamic(next_song)
s = fade.out(fade.in(cue_cut(s)))
output(s)