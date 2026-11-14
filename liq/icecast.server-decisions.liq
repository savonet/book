#!./liquidsoap
# header
def evening_only(_) =
  if
    time.local().hour < 18
  then
    {refuse = icecast.server.refusal(reason="Back at 6 pm", 403)}
  else
    {refuse = null}
  end
end

members =
  icecast.server.decision.all(
    [
      icecast.server.decision.access_lists(deny="/etc/radio/banned.txt"),
      icecast.server.decision.htpasswd("/etc/radio/members.htpasswd"),
      evening_only
    ]
  )

def mount(mountpoint) =
  mountpoint == "/members.mp3" ? {listener_decision = members} : null
end

icecast.server({source_password = "hackme", mount = mount})
