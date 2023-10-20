# Cutting-edge packages

On Ubuntu and Debian, you can also have access to the packages which are
automatically built for the latest version. This allows for quick testing of the
latest features, but we do not recommend them for production purposes. In order
to have access to those, first install the repository signing key:

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 20D63CCDDD0F62C2
```

and then add the following source for Ubuntu:

```
echo deb http://deb.liquidsoap.info/ubuntu bionic main | sudo tee -a /etc/apt/sources.list
```

The above line is for the Bionic version of Ubuntu, if you are on Debian/testing
or Debian/stretch, replace `ubuntu` by `debian` and `bionic` by `testing` or `stretch`.

Finally, update your packages list:

```
sudo apt update
```

You can now see the list of available packages:
```
apt-cache show liquidsoap
```

Package names are of the form: `liquidsoap-<commit>` or
`liquidsoap-<branch>`. _commit_ is an identifier for the last modification
and _branch_ are used to develop features (the default branch being named 
`master`). For instance, to install the latest `master`, you can do:

```
sudo apt install liquidsoap-master
```

# Daemonizing the script

If you need to run liquidsoap as daemon, we provide a package named
`liquidsoap-daemon`.  See
[savonet/liquidsoap-daemon](https://github.com/savonet/liquidsoap-daemon) for
more information.

The full installation of liquidsoap will typically install
`/etc/liquidsoap`, `/etc/init.d/liquidsoap` and `/var/log/liquidsoap`.
All these are meant for a particular usage of liquidsoap
when running a stable radio.

Your production `.liq` files should go in `/etc/liquidsoap`.
You'll then start/stop them using the init script, *e.g.*
`/etc/init.d/liquidsoap start`.
Your scripts don't need to have the `#!` line,
and liquidsoap will automatically be ran on daemon mode (`-d` option) for them.

You should not override the `log.file.path` setting because a
logrotate configuration is also installed so that log files
in the standard directory are truncated and compressed if they grow too big.

It is not very convenient to detect errors when using the init script.
We advise users to check their scripts after modification (use
`liquidsoap --check /etc/liquidsoap/script.liq`)
before effectively restarting the daemon.
