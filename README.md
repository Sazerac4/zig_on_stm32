
- [Context](#context)
- [Examples List](#examples-list)
- [Installation](#installation)
  - [Linux](#linux)
  - [Windows](#windows)
  - [Containers (Podman or Docker)](#containers-podman-or-docker)
  - [Vs Code / Vs Codium](#vs-code--vs-codium)
- [SVD Files](#svd-files)
- [Build](#build)
- [Debugging CLI](#debugging-cli)
- [Linker Note](#linker-note)
- [Reference:](#reference)


## Context

Are you considering incorporating Zig code into your embedded development projects, specifically on STM32 or other similar platforms?  
If so, I'd like to share some demo examples that demonstrate how to  integrate Zig code into your projects.  
These examples utilize the STM32CubeMX code generator as well as the drivers provided by ST, which are probably already integrated into your projects and which you want to keep.

## Examples List

- Bare-metal blinky example with C and Zig implementation 
- FreeRTOS blinky example with C and Zig implementation 

**Project tree**

```
projects/
└── stm32l476_nucleo/
    ├── blinky/
    ├── blinky_picolibc/
    └── blinky_freertos/
```

## Installation

**Tools:**

| Name              | Version   | Description                                                             |
| :---------------- | --------- | :---------------------------------------------------------------------- |
| Zig               | `0.14.0`  | for compiling C and Zig code                                            |
| Arm GNU Toolchain | `14.2.1`  | to provide the libc (newlib) needed by C source code                    |
| ST link           | `v1.8.0`  | for flashing firmware                                                   |
| OpenOCD           | `v0.12.0` | to provide debugging                                                    |
| CMake             | `3.30.5`  | for build automation                                                    |
| STM32CubeMX       | `6.13.0`  | for the generation of the corresponding initialization C code for STM32 |


Some of theses tools are downloaded from the [xPack Binary Development Tools](https://xpack-dev-tools.github.io/) project.

### Linux

```bash
#Fedora
yum install cmake make wget stlink openocd
#Debian
apt install cmake make wget stlink-tools openocd xz-utils

#Create folder softs
mkdir -vp /opt/softs

#Install arm-none-eabi-gcc (xpack version)
GCC_VERSION="14.2.1-1.1"
cd /tmp && wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v${GCC_VERSION}/xpack-arm-none-eabi-gcc-${GCC_VERSION}-linux-x64.tar.gz \
    && tar -xf /tmp/xpack-arm-none-eabi-gcc-*-linux-x64.tar.gz -C /opt/softs/ \
    && ln -s /opt/softs/xpack-arm-none-eabi-gcc-*/bin/arm-none-eabi-*  ~/.local/bin

#Install zig
ZIG_VERSION="0.14.0-dev.3046+08d661fcf"
cd /tmp && wget https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
    tar -xf /tmp/zig-linux-x86_64-*.tar.xz -C /opt/softs/ && \
    ln -s /opt/softs/zig-linux-x86_64-*/zig ~/.local/bin
```

### Windows

1. Create a `softs` folder (example : `C:\softs` )
2. Download [zig](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.3046+08d661fcf.zip)
3. Download [arm-none-eabi-gcc](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v14.2.1-1.1)
4. Download [stlink](https://github.com/stlink-org/stlink/releases/tag/v1.8.0)
5. Download [openocd](https://github.com/xpack-dev-tools/openocd-xpack/releases/tag/v0.12.0-4)
6. Extract everything to the folder `softs`

- Download [cmake](https://cmake.org/download/) and install it.

**Setup environnement variables**

Here, the command to setup environnement variable according to the instructions below.
You need to choice between System wide or User level. Example below work if you use `C:\softs` 

- System wide (admin Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\softs\xpack-openocd-0.12.0-4\bin",
   "Machine"
)
```
- User level (Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0-dev.3046+08d661fcf;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\softs\xpack-openocd-0.12.0-4\bin",
   "User"
)
```

### Containers (Podman or Docker)

Instead of installing the various tools separately, you can install Docker or Podman and build/flash the firmware directly from the container.

```bash
#Create the image
podman build -f ContainerFile --tag=zig_on_stm32:0.14.0 .
#Run a container
podman run --rm -it --privileged -v ./projects:/apps --name=zig_on_stm32 zig_on_stm32:0.14.0
# Navigate to a project (example blinky)
cd stm32l476_nucleo/blinky
```

Remove dangling image if needed : `podman image prune`

### Vs Code / Vs Codium

For `Vs Code` User, all project got à `.vscode` folder with à `launch.json` for debugging and à `tasks.json` to build and upload the firmware.
You can download theses extensions:

- `marus25.cortex-debug` for debugging ARM Cortex-M targets.

(image)

- `actboy168.tasks` to got quick shortcut of your tasks in your status bar

(image)

## SVD Files

The CMSIS System View Description format(CMSIS-SVD) formalizes the description of the system contained in Arm Cortex-M processor-based microcontrollers, in particular, the memory mapped registers of peripherals.

- You can use [regz](https://github.com/ZigEmbeddedGroup/microzig/tree/main/tools/regz) to generate `registers` code.
- You can use it with VS Code in debugging mode

(image)

You can found stm32 svd files [here](https://github.com/modm-io/cmsis-svd-stm32)

## Build

- See the `README.md` for each project for specific options and instructions

## Debugging CLI

Example with `blinky` project In a terminal, navigate to the directory project `projects/stm32l476_nucleo/blinky`, then run
   
```bash
openocd -c "gdb_port 50000" -c "tcl_port 50001" -c "telnet_port 50002" -s ./ -f interface/stlink.cfg -f target/stm32l4x.cfg
```

From another terminal in the same folder, run:

```bash
arm-none-eabi-gdb zig-out/bin/blinky.elf -ex "target extended-remote :50000"
```

You can flash the firmware inside gdb with:

```bash
load
```

## Linker Note

- We need to move the declaration for `_estack` to after the region `RAM` is defined. 
- The section `_user_heap_stack` is in RAM (and thus wont' be flashed to the device), so it really should be marked with `(NOLOAD)` like so:

```ld
/* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM
```

More details with this [STM32 Guide](https://github.com/haydenridd/stm32-zig-porting-guide/tree/main/02_drop_in_compiler#modifying-our-linker-script)

## Reference:

- [STM32 Guide](https://github.com/haydenridd/stm32-zig-porting-guide) will help you to understand and port your current project. Ziggit topic [here](https://ziggit.dev/t/stm32-porting-guide-first-pass/4414)
- This project may interest you: [Microzig](https://github.com/ZigEmbeddedGroup/microzig) A Unified abstraction layer and HAL for several microcontrollers
- FreeRTOS discussion on [ziggit.dev](https://ziggit.dev/t/exploring-zig-on-stm32-with-freertos/4653)