# Radio
A command-line internet radio player.

It uses `<linux/input.h>` to catch global keyboard events, so it only works on Linux for the moment.

## Requirements

- [Swift](https://swift.org/download/#releases)
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
