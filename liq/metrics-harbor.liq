#!./liquidsoap
%include "metrics.liq"
def metrics_page(~protocol, ~data, ~headers, uri)
  data = json.stringify(metrics())
  http.response(content_type="application/json", data=data)
end
harbor.http.register("/metrics", metrics_page)
output(s)
