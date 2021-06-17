#!./liquidsoap
%ifdef output.alsa
print("We have support for ALSA.")
%else
print("We don't have support for ALSA.")
%endif
