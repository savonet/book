#!./liquidsoap
radio = mksafe(playlist("~/Music")) radio = source.run(radio, every=2., {radio.skip()})
def on_file(fname)
  log.important("Making a backup of #{fname}.")
  process.run("cp #{fname} /radio/backup/")
end
output.file(%mp3, "archive/%Y-%m-%d/%H-%M-%S.mp3", radio,
            reopen_when={0m}, on_close=on_file)
