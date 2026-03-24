#!./liquidsoap
s = single("video.mkv")
# This will fail — metadata and track_marks belong to a different clock:
let {audio, metadata, track_marks} = source.tracks(s)
encoded_audio = track.ffmpeg.encode.audio(%ffmpeg(%audio(codec="aac")), audio)
encoded = source({audio=encoded_audio, metadata=metadata,
                  track_marks=track_marks})
