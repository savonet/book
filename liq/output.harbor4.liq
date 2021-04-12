#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.harbor(%mp3(bitrate=192,stereo_mode="joint_stereo"),
              mount="my-radio.mp3", radio)
