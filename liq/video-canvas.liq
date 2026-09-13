#!./liquidsoap
# header
let {px, rem, vh, vw, width, height} = video.canvas.virtual_10k.actual_720p
settings.frame.video.width := width
settings.frame.video.height := height
s = video.add_image(x=0.05 @ vw, y=0.05 @ vh, width=1200 @ px,
                    file="logo.png", blank())
s = video.add_text(size=1.5 @ rem, x=234 @ px, y=4437 @ px, speed=0,
                   "Hello world!", s)
output.audio_video(fallible=true, s)
