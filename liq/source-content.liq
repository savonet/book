#!/usr/bin/env liquidsoap
s = source.mux.video(video=video.fill(color=0x0000ff, blank()), sine())
def show_content() =
  list.iter(
    fun (tf) -> print("#{fst(tf)}: #{format.description(snd(tf))}"),
    source.content(s)
  )
end
thread.run(delay=1., show_content)
output.audio_video(s)
