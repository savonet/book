#!./liquidsoap
log.level.set(5)
enable_replaygain_metadata(extract_replaygain="/home/smimram/.opam/4.10.0/lib/liquidsoap/share/liquidsoap/git/c4eee64f/bin/extract-replaygain")
s = playlist(native=true, "~/Music")
s.on_track(fun (m) -> print("Replaygain of #{m['title']}: #{m['replay_gain']}"))
s = skipper(s)
output(s)