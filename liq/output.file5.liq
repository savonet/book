#!./liquidsoap
radio = mksafe(playlist("~/Music"))
radio = source.run(radio, every=2., {radio.skip()})
# header
def on_file(fname)
  log.important("Making a backup of #{fname}.")
  process.run("cp #{fname} /radio/backup/")
end
def on_error(err)
  log.severe("Could not archive the file: #{err}")
  10.
end
output.file(%mp3, {time.string("archive/%Y-%m-%d/%H-%M-%S.mp3")}, radio,
            reopen_when={0m}, on_close=on_file, reopen_on_error=on_error)
