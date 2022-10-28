#!./liquidsoap
rock = mksafe(playlist("~/Music")) techno = rock
def out(~mount, enc, s) =
  output.icecast(host="localhost", port=8000, password="hackme", mount=mount, enc, s)
end
out(mount="rock.mp3",   %mp3,     rock)
out(mount="rock.aac",   %fdkaac,  rock)
out(mount="techno.mp3", %mp3,     techno)
out(mount="techno.aac", %fdkaac,  techno)
