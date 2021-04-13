#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%fdkaac(channels=2, bandwidth="auto", bitrate=64, afterburner=false,
        aot="mpeg2_he_aac_v2", transmux="adts", sbr_mode=false)
, "/tmp/out", s)
