- liquidsoap-full is deprecated
- `self_sync` for `input.ffmpeg`, see
  <https://github.com/savonet/liquidsoap/issues/1689>
- `clock_safe` vs `self_sync`, see
  <https://github.com/savonet/liquidsoap/issues/1687>
- mentionner les autres images docker comme
  <https://github.com/PhasecoreX/docker-liquidsoap>
- les problèmes de seek FFmpeg devraient être ok
  <https://github.com/savonet/liquidsoap/issues/1706>
- smart crossfade is called `cross.smart`, see also `cross.simple`
- pour le multicore, FFmpeg fait ça bien:

  ```
  b = noise()
  clock.assign_new(sync='none',[b])
  output.file(%ffmpeg(%audio(codec="aac", b="128k"), %video(codec="libx264")), "/tmp/one.mp4", b)
  output.file(%ffmpeg(%audio(codec="aac", b="128k"), %video(codec="libx264")), "/tmp/two.mp4", b)
  ```

- les settings (#1722)
- `--conf-descr` renommé en `--list-settings`
- `dtmf.detect` dtmf detection
- playlists only have given number of requests in advance and not time anymore
  (#1791)
- mention `output.youtube.live`
- regexps #1881
- cons notation for lists
- interactive unit (#2075)
- patterns for records, etc.
- `output.harbor`
- video resizing, etc.

- progress bar on videos [#3149](https://github.com/savonet/liquidsoap/discussions/3149).
- script pour les covers [#3509](https://github.com/savonet/liquidsoap/discussions/3509)

- using chatGPT
- ffmpeg filters : https://github.com/savonet/liquidsoap/discussions/3554
- move metadata from one track : https://github.com/savonet/liquidsoap/discussions/3555
- ?? operator : https://github.com/savonet/liquidsoap/discussions/3535
