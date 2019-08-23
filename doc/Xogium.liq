#set("log.stdout",true)
#set("log.level",4)
#set("server.telnet",true)
set("server.timeout",-1.)
source = mksafe(playlist("/var/lib/liquidsoap/royalty",reload_mode="watch",mode="random"))
## Better audio processing:
# Functions / Modules --------------------->

# Compressor Module / Limiter Module
compressor = ladspa.sc4(rms_peak = 0.5)
limiter = ladspa.tap_limiter(limit_level = -0.5)

# Single Band Compressor
def multiband_band(source, from, to, attack, release, ratio, threshold, gain)
	from_filter = filter.iir.eq.high(frequency = from,)
	to_filter = filter.iir.eq.low(frequency = to,)
	source_filtered = to_filter(from_filter(source))
	source_compressed = limiter(compressor(attack_time = attack, release_time = release, threshold_level = threshold, ratio=ratio, makeup_gain = gain, source_filtered))
	source_compressed
end

# Processing Blocks --------------------->

# Gate
source = ladspa.gate(source, threshold = -80.0, attack = 0.15, hold = 1.0, decay = 200.0, range = -25.0)

# Wideband AGC + Pre-Processing
source = normalize(gain_min = -16., gain_max = 0., target = 0.5, source)
source = ladspa.sc4(rms_peak=0.3, attack_time = 0.5, release_time = 3., threshold_level = -36.0, ratio=1., makeup_gain = 6., source)

# Stereo Expander
#source = ladspa.matrixspatialiser(width=16, source)

# Bass EQ
source = ladspa.tap_equalizer(band_1_freq=70., band_1_gain=4., source)
source = ladspa.tap_equalizer(band_1_freq=150., band_1_gain=-2., source)

# 5 Bands Compress/Limit
source = add(normalize=false,
  [
  multiband_band(source, 0., 200., 3.5, 30., 3., -10., 2.),
  multiband_band(source, 200., 1000., 2.25, 40., 2., -13., 2.),
  multiband_band(source, 1000., 3500., 2.25, 40., 3., -9., 2.),
  multiband_band(source, 3500., 6500., 2.25, 60., 2., -6., 1.5),
  multiband_band(source, 6500., 20000., 2.25, 70., 2., -4., 1.)
  ])

# 2 Bands Compress/Limit
#source = add(normalize=false,
#  [
#  multiband_band(source, 0., 200., 10., 30., 2., -4., 0.),
#  multiband_band(source, 200., 20000., 10., 40., 2., -2., -2.)
#  ])

# De-esser
source = ladspa.tap_deesser(threshold_level=-5., frequency=6000., source)

# Final Limiter
source = limiter(source)

def append_album(m) =
	title = m["title"]
	artist = m["artist"]
	album = m["album"]
	[("artist","#{artist}"),("title","#{album} - #{title}")]
end

source = map_metadata(append_album, source)

output.icecast(%mp3.cbr(bitrate=320, samplerate=44100),
	protocol = "https",
	host = "some_host",
	port = 8443,
	id = "rmp3",
	mount = "/mount_point.mp3",
	password = "some_pass",
	name = "some_name",
	description = "some_description",
source)
