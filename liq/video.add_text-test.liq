#!./liquidsoap
log.level.set(5)
s = single("jo.mp4")
s = video.add_text.native(color=0xff0000, "Hello world!", s)
# s = video.add_text.sdl(color=0xff0000, "Hello world!", s)
# s = video.add_text.gstreamer(color=0xff0000, "Hello world!", s)
# s = video.add_text.gd(color=0xff0000, "Hello world!", s)
# s = video.add_text.ffmpeg(color=0xff0000, "Hello world!", s)
output.audio_video(s)
