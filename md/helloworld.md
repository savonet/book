Setting up a simple radio station
=================================

En gros reprendre le
[QUICKSTART](https://www.liquidsoap.info/doc-dev/quick_start.html).

Hello, world!
-------------

Our first program looks like this:
```
liquidsoap `out(sine())`
```
We could have written it
```liquidsoap
#!/usr/bin/liquidsoap
out(sine())
```
or better, we give a name `s` to the source
```liquidsoap
#!/usr/bin/liquidsoap
# this is our source
s = sine()
out(s)
```

The path will be more like , use to know the path

Our first radio with a playlist
-------------------------------

EN GROS:
```liquidsoap
output.icecast(playlist("~/music/"))
```

Streams depending on the hour
-----------------------------

un switch
