#!./liquidsoap
# log.level := 5
interactive.harbor()
# s = playlist("~/Music")
s = single("/home/smimram/Music/albums/Gonzales/Gonzales - solo piano/09 Paristocrats.mp3")
s = normalize(s)
n = s.gain
ratio = interactive.float("ratio", 5.)
wet = interactive.float("wet", min=0., max=1., 1.)
threshold = interactive.float("threshold", min=-40., max=0., -10.)
s = compress(ratio=ratio, wet=wet, threshold=threshold, s)
# s = compress.old(ratio=ratio, threshold=-10., s).{gain = fun()->0.}
# s = ladspa.sc4(ratio=ratio, threshold_level=threshold, s).{gain = fun()->0.}
s = source.run(s, every=.5, {print("norm: #{n()}\tgain: #{s.gain()}")})
output(s)
output.file(fallible=true, %wav, "/tmp/out.wav", s)
