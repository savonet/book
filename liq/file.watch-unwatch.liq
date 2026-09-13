#!./liquidsoap
def on_request() = () end
# header
w = file.watch("to-play", on_request)
# ...
w.unwatch()
