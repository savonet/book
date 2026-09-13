#!./liquidsoap
mic = input.alsa()
v = ref(1.2)
# header-a
def volume () = 1.2 end
radio = amplify(volume, mic)
# footer-a
ignore(radio)
# header-b
radio = amplify(fun () -> 1.2, mic)
# footer-b
ignore(radio)
# header-c
radio = amplify({1.2}, mic)
# footer-c
ignore(radio)
# header-d
radio = amplify({v()}, mic)
# footer-d
ignore(radio)
# header-e
radio = amplify(v, mic)
# footer-e
ignore(radio)
# header-f
radio = amplify({2. * v()}, mic)
# footer-f
output(radio)
