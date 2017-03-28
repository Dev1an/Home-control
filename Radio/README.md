# Radio
A simple internet radio player (currently only plays Radio Maria België).

## Requirements

- [Swift](https://swift.org/download/#releases)
- [libmpv](mpv.io)
  - Ubuntu: `sudo apt install libmpv-dev`
  - macOS: `brew install mpv`

## Build

### macOS

```shell
swift build -Xlinker -L/usr/local/lib/
```