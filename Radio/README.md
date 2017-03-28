# Radio
A command-line internet radio player (currently only plays Radio Maria België).

It has no dependencies to Apple frameworks like Foundation or AppKit so it can be used on any platform supporting swift and mpv.

## Requirements

- [Swift](https://swift.org/download/#releases)
- [libmpv](mpv.io)
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