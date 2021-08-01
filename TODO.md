- the `active_source` type should be removed (see #1671), rework the explanation
  of active sources
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
