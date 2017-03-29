# Radio
A command-line internet radio player (currently only plays Radio Maria België).

It uses `<linux/input.h>` to catch global keyboard events, so it only works on Linux for the moment.

## Requirements

- [Swift](https://swift.org/download/#releases)
- [libmpv](https://mpv.io)
  - Ubuntu: `sudo apt install libmpv-dev`
  - macOS: `brew install mpv`
  - Raspbian:
    - sudo apt-get install -y gperf bison flex autoconf automake make texinfo help2man libtool libtool-bin ncurses-dev git yasm mercurial cmake cmake-curses-gui libfribidi-dev checkinstall libfontconfig1-dev libgl1-mesa-dev libgles2-mesa-dev gnutls-dev libsmbclient-dev libpulse-dev libbluray-dev libdvdread-dev libluajit-5.1-dev libjpeg-dev libv4l-dev libcdio-cdda-dev libcdio-paranoia-dev
    - git clone https://github.com/mpv-player/mpv-build.git
    - cd mpv-build
    - echo --enable-mmal >> ffmpeg_options
    - echo --enable-libmpv-shared > mpv_options
    - ./use-mpv-release
    - ./use-ffmpeg-release
    - ./update
    - ./rebuild -j4
    - shell `sudo ./install`
## Build

```shell
swift build
```
## Run

```shell
.build/debug/Radio
```
