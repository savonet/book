Setting up a simple radio station
=================================

En gros reprendre le
[QUICKSTART](https://www.liquidsoap.info/doc-dev/quick_start.html).

Hello, world!
-------------

Our first program looks like this:

```liquidsoap
#!/usr/bin/liquidsoap
s = sine()
out(s)
```

The path will be more like , use to know the path

Our first radio with a playlist
-------------------------------

    EN GROS:
    output.icecast(playlist("~/music/"))

Streams depending on the hour
-----------------------------

un switch
