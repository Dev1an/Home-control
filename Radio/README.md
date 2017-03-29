# Radio
A command-line internet radio player.

It uses `<linux/input.h>` to catch global keyboard events, so it only works on Linux for the moment.

## Requirements

- [Swift](https://swift.org/download/#releases)
- [libmpv](https://mpv.io)
  - Ubuntu: `sudo apt install libmpv-dev`
  - macOS: `brew install mpv`

## Build

```shell
swift build
```

### Release

```shell
swift build -c release
```

## Run

The radio executable takes one argument: the path to the remote.
```shell
.build/debug/Radio /dev/input/event2
```
Use the function keys to change the channel
