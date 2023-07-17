#!./liquidsoap
radio = mksafe(playlist("~/Music")) radio = source.run(radio, every=2., {radio.skip()})
output.file(%mp3,
            {time.string("archive/%Y-%m-%d/$(artist) - $(title).mp3")},
            radio, reopen_on_metadata=true)
