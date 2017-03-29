# Radio
A command-line internet radio player (currently only plays Radio Maria België).

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
## Run

```shell
.build/debug/Radio
```
