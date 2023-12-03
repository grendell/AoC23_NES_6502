# AoC 2023 2-1 in NES-compatible 6502 Assembly
* [Advent of Code 2023 Day 2](https://adventofcode.com/2023/day/2)

![Preview Screenshot](2-1.png)
## Preparation
* Copy your unique input into `2-1.txt` in the project root.
## Building
* Simply run `make`
    * Requires `ca65`, `ld65`, and `clang` to be included in your PATH.
## File Summary
* `2-1.s`
    * Complete source code in 6502 assembly.
* `2-1.bin`
    * Reformatted input in binary format (no preprocessing).
* `nes.cfg`
    * Linker configuration for basic [NES NROM](https://www.nesdev.org/wiki/NROM) rom file.
* `2-1.nes`
    * Prebuilt rom file.