Internals
=========

The OCaml language
------------------

The stream model
----------------
## Frames

## Ticks

## Track boundaries

En gros, chaque appel a `get_frame` doit ajouter exactement un break. Si le
break est en fin de frame, on a fini sinon c'est une fin de piste.

## Metadata

The source model
----------------
## Clocks

[See here](https://github.com/savonet/liquidsoap/issues/288)

## Seeking

## Active / passive sources

what are those???

Requests
--------

The purpose of a request is to get a valid file. The file can contain media in
which case validity implies finding a working decoder, or can be something
arbitrary, like a playlist. This file is fetched using protocols. For example
the fetching can involve querying a mysql database, receiving a list of new
URIS, using http to download the first URI, check it, fail, using smb to
download the second, success, have the file played, finish the request, erase
the temporary downloaded file. This process involve a tree of URIs, represented
by a list of lists.  Metadata is attached to every file in the tree, and the
view of the metadata from outside is the merging of all the metadata on the path
from the current active URI to the root.  At the end of the previous example,
the tree looks like:

```
[ [ "/tmp/localfile_from_smb" ] ;
  [
    (* Some http://something was there but was removed without producing
     * anything. *)
    "smb://something" ; (* The successfully downloaded URI *)
    "ftp://another/uri" ;
    (* maybe some more URIs are here, ready in case of more failures *)
  ] ;
  [ "mydb://myrequest" ] (* And this is the initial URI *)
]
```


Libraries around Liquidsoap
---------------------------

How to contribute
-----------------

### Getting stacktraces

```
% gdb -p <process PID>
> thread apply all bt
```
