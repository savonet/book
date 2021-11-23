#!./liquidsoap
radio1 = playlist("~/Music") radio2 = playlist("~/Music")
settings.prometheus.server.set(true)
settings.prometheus.server.port.set(9090)
rms_metric = prometheus.gauge(
  labels=["source"], help="RMS power", "liquidsoap_rms")
set_radio1_rms_metric = rms_metric(label_values=["radio1"])
set_radio2_rms_metric = rms_metric(label_values=["radio2"])
radio1 = rms(radio1)
radio2 = rms(radio2)
thread.run(every=1., {set_radio1_rms_metric(radio1.rms())})
thread.run(every=1., {set_radio1_rms_metric(radio2.rms())})
output(radio1)
