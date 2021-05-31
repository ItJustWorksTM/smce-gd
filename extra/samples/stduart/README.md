# StdUart

_UART (`Serial`) piped to {`stdout`, `stdin`}_

**WARNING**: This program is not installable, nor portable (it is however relocatable). It is only meant to be ran from its build tree.

**CAVEAT**: For a reason still unknown at this time, using an SMCE built with GCC but compiling _StdUart_ with Clang causes segfaults to occur. 

Like SMCE, this sample program requires a C++20 toolchain (for `<span>` mostly).

## Build

```shell
cmake -S . -B build/
cmake --build build/
```

You can now find the executable in the `./build` directory.

## Usage
```
stduart <fqbn> <sketch-path>
```
where
- FQBN: [Fully Qualified Board Name](https://arduino.github.io/arduino-cli/latest/FAQ/#whats-the-fqbn-string)
- Sketch path: Relative or absolute path to the sketch to run

As-is, the board may not access any GPIO pins, and the pseudo-SD card is mounted to `$(pwd)`.

To quit the program, type `~QUIT` and press &lt;Enter&gt;

## Sketches

At the current time, we only provide a single sample sketch for _StdUart_, under `sketches/`

### - `echo`
The `echo` sketch copies what it receives on its UART0 RX to UART0 TX.