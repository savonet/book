#!./liquidsoap
s = (single("..."):source(audio=ffmpeg.audio.raw(sample_rate=44100, channel_layout="5.1"),video=ffmpeg.video.raw(pixel_format=yuva420p, pixel_aspect="16:9"),midi=midi))
ignore(s)