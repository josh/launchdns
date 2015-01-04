# dns

A launchd friendly development loopback DNS server.

```
dns [-spt46]
```


## Installation

```
$ make
$ make install [PREFIX=<prefix>]
````


## Usage

```
$ dns -p 53
```


## Options

* `-s` name, ``--socket`=name

Name of key in Launchd Sockets dictionary to bind to. If name is set, the `-p` option is ignored.

* `-p` num, `--port`=num

Port number to bind to. Defaults to 55353.

* `-t` num, `--timeout`=num

Number of seconds to run for. Will run indefinitely by default.

* `-4` addr, `--a`=addr

IPv4 address for all A responses. Defaults to 127.0.0.1.

* `-6` addr, `--aaaa`=addr

IPv6 address for all AAAA responses. Defaults to ::1.


## Launch Agent configuration

The most basic way is setup a run at load agent that binds to the default port.

**~/Library/LaunchAgents/com.github.josh.dns.plist**

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.josh.dns</string>
	<key>RunAtLoad</key>
	<true/>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/dns</string>
	</array>
</dict>
</plist>
```

This will keep `dns` running on port 55353 anytime you log into your computer.

Though, the preferred way to configure the server to run on demand.

**~/Library/LaunchAgents/com.github.josh.dns.plist**

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.josh.dns</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/dns</string>
		<string>--socket=Socket</string>
		<string>--timeout=30</string>
	</array>
	<key>Sockets</key>
	<dict>
		<key>Socket</key>
		<dict>
			<key>SockType</key>
			<string>dgram</string>
			<key>SockNodeName</key>
			<string>127.0.0.1</string>
			<key>SockServiceName</key>
			<string>55353</string>
		</dict>
	</dict>
</dict>
</plist>
```

Instead of the server being started at load, it will automatically start on demand when theres activity on 127.0.0.1:55353. And after 30 seconds, it will quit until it needs to be launched again. Note the `--socket` name matches the name of the Socket dictionary key.


## See Also

launchd(8), launchctl(1), launchd.plist(5), launch(3), resolver(5)
