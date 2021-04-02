#!./liquidsoap
rock = mksafe(playlist("~/Music")) techno = rock
out = output.icecast(host="localhost", port=8000, password="hackme")
out(%mp3,    mount="rock.mp3",   rock)
out(%fdkaac, mount="rock.aac",   rock)
out(%mp3,    mount="techno.mp3", techno)
out(%fdkaac, mount="techno.aac", techno)
