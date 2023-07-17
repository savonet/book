#!./liquidsoap
radio = mksafe(playlist("~/Music"))
f = output.file(%mp3,
            {time.string("archive/%Y-%m-%d/%H-%M-%S.mp3")},
            radio)
thread.when({0m}, f.reopen)