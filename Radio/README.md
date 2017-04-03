# Radio
A command-line internet radio player.

It uses `<linux/input.h>` to catch global keyboard events, so it only works on Linux for the moment.

## Requirements

- [Swift](https://swift.org/download/#releases)
  - Ubuntu Mate 16.04 (RPi)
    - enable ssh: `sudo systemctl enable ssh.service`
    
    - download https://www.dropbox.com/s/cah35gf5ap22d11/swift-3.0.2-RPi23-1604.tgz

    - `sudo apt-get install clang`
    
    - put path in ~/.profile `PATH=/home/michel/Documents/swift/usr/bin:"${PATH}"`
    
- [libmpv](https://mpv.io)
  - Ubuntu: `sudo apt install libmpv-dev libssl-dev libcurl4-openssl-dev uuid-dev `
  - macOS: `brew install mpv`

## Develop

Generate xcode project to develop in Xcode

```shell
swift package generate-xcodeproj
```

## Build

**Update packages**
Since the /Packages directory is ignored by git, one has to manually update dependencies after pulling new commits from github.
```shell
swift package update
```

**build for debugging**

```shell
swift build
```

**build release**

```shell
swift build -c release
```

## Run

The radio executable takes one argument: the path to the remote.
```shell
.build/debug/Radio /dev/input/event2
```
Use the function keys to change the channel, press <kbd>backspace</kbd> to stop playing.

## Startup script

put script in /usr/local/bin/radio.sh:
```shell
#!/bin/bash
# Automatically restarting server from stackoverflow.com/a/697064

until /home/michel/Documents/Home-control/Radio/.build/debug/Radio
do
    echo `basename "$0"` "server crashed with exit code $?.  Respawning.." >&2
    sleep 1
done
```
Make logfile: `touch /var/log/radio.log`

Edit crontab: `crontab -e`
```shell
@reboot /usr/local/bin/radio.sh >> /var/log/radio.log
```
