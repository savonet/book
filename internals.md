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

Libraries around Liquidsoap
---------------------------

How to contribute
-----------------

### Getting stacktraces

```
% gdb -p <process PID>
> thread apply all bt
```
