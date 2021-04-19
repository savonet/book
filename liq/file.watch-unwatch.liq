#!./liquidsoap
def on_request() = () end
w = file.watch("to-play", on_request)
# ...
w.unwatch()
