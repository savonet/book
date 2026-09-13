#!./liquidsoap
radio = mksafe(playlist("~/Music"))
# header
output.file(%mp3,
            {time.string("archive/%Y-%m-%d/%H-%M-%S.mp3")},
            radio, reopen_when={0m})
