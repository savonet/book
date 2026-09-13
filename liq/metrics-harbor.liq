#!./liquidsoap
%include "metrics.liq"
# header
def metrics_page(_)
  data = json.stringify(metrics())
  http.response(content_type="application/json", data=data)
end
harbor.http.register.simple("/metrics", metrics_page)
# footer
output(s)
