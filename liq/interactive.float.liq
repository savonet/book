#!./liquidsoap
# header
a = interactive.float("main_volume", description="Our volume",
                      min=0., max=3., 1.)
# footer
ignore(a)
