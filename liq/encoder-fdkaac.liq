#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%fdkaac(channels=2, bandwidth="auto", bitrate=64, afterburner=false,
        aot="mpeg2_he_aac_v2", transmux="adts", sbr_mode=false)
# footer
, "/tmp/out", s)
