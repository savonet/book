#!./liquidsoap
radio1 = playlist("~/Music")
radio2 = playlist("~/Music")
# header-a
settings.prometheus.server := true
settings.prometheus.server.port := 9090
# footer-a
# header-b
rms_metric = prometheus.gauge(
  labels=["source"], help="RMS power", "liquidsoap_rms")
# footer-b
# header-c
set_radio1_rms_metric = rms_metric(label_values=["radio1"])
set_radio2_rms_metric = rms_metric(label_values=["radio2"])
# footer-c
# header-d
radio1 = rms(radio1)
radio2 = rms(radio2)
thread.run(every=1., {set_radio1_rms_metric(radio1.rms())})
thread.run(every=1., {set_radio2_rms_metric(radio2.rms())})
# footer-d
output(radio1)
