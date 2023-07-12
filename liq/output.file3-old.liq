#!./liquidsoap
radio = mksafe(playlist("~/Music"))
def should_reopen(~metadata, ~error)
  if null.defined(metadata) or null.defined(error) then
    -1.
  else
    3600.
  end
end
output.file(%mp3, {time.string("archive/%Y-%m-%d/%H-%M-%S.mp3")}, radio,
            should_reopen=should_reopen)
