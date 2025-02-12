
- [Description](#description)
- [Examples List](#examples-list)
- [Installation](#installation)
  - [Linux](#linux)
  - [Windows](#windows)
  - [Containers (Podman or Docker)](#containers-podman-or-docker)
  - [Vs Code / Vs Codium](#vs-code--vs-codium)
- [SVD Files](#svd-files)
- [Build](#build)
- [Debugging CLI](#debugging-cli)
- [For STM32CubeMX generated linker script](#for-stm32cubemx-generated-linker-script)
- [References](#references)


## Description

[Zig](https://ziglang.org/) is a language that seems perfect for embedded systems programming, and you might be considering incorporating Zig code into your embedded development projects. However, there are several reasons why you might not want just to start a project with it.

- You use a manufacturer-specific software generator (e.g., STM32CubeMX) to simplify device initialization and peripheral configuration. The generated code is in C.
- The project already exists, and rewriting it is not an option.
- Your future project rely heavily on C-based components, such as operating systems (e.g., FreeRTOS), filesystems (e.g., LittleFS), libraries, drivers, etc. You don’t want to rewrite initialization or configuration routines that already work well and are widely used elsewhere.
- You work with coworkers who will maintain, update, and/or test parts of the project's C code. They may not use Zig—either not yet or never.

In this repository, I’d like to share some demo examples that demonstrate how to integrate Zig code into your existing projects. I’ll also include the tools I used to do the cross-development between C and Zig.

## Examples List

1. Blinky Example 
2. Blinky Example with custom PicolibC build
3. Blinky Example with FreeRTOS 

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
| Clang             | `19.1.7`  | for compiling the libc (picolibc)                                       |
| ST link           | `v1.8.0`  | for flashing firmware                                                   |
| OpenOCD           | `v0.12.0` | to provide debugging                                                    |
| STM32CubeMX       | `6.13.0`  | for the generation of the corresponding initialization C code for STM32 |


Some of theses tools are downloaded from the [xPack Binary Development Tools](https://xpack-dev-tools.github.io/) project.

### Linux

```bash
#Fedora
yum install make wget stlink openocd
#Debian
apt install make wget stlink-tools openocd xz-utils

#Create folder softs
mkdir -vp /opt/softs

#Install arm-none-eabi-gcc (xpack version)
GCC_VERSION="14.2.1-1.1"
cd /tmp && wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v${GCC_VERSION}/xpack-arm-none-eabi-gcc-${GCC_VERSION}-linux-x64.tar.gz \
    && tar -xf /tmp/xpack-arm-none-eabi-gcc-*-linux-x64.tar.gz -C /opt/softs/ \
    && ln -s /opt/softs/xpack-arm-none-eabi-gcc-*/bin/arm-none-eabi-*  ~/.local/bin

#Install zig
ZIG_VERSION="0.14.0-dev.3050+d72f3d353"
cd /tmp && wget https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
    tar -xf /tmp/zig-linux-x86_64-*.tar.xz -C /opt/softs/ && \
    ln -s /opt/softs/zig-linux-x86_64-*/zig ~/.local/bin
```

### Windows

1. Create a `softs` folder (example : `C:\softs` )
2. Download [Zig](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.3050+d72f3d353.zip)
3. Download [Arm GNU Toolchain](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v14.2.1-1.1)
4. Download [ST link](https://github.com/stlink-org/stlink/releases/tag/v1.8.0)
5. Download [OpenOCD](https://github.com/xpack-dev-tools/openocd-xpack/releases/tag/v0.12.0-4)
6. Extract everything to the folder `softs`

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
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0-dev.3050+d72f3d353;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\softs\xpack-openocd-0.12.0-4\bin",
   "User"
)
```

### Containers (Podman or Docker)

Instead of installing the various tools in your system, you can use containers to build or flash the firmware.
Two technologies exist, both CLI APIs are mostly compatible: the well-known Docker and Podman. I use Podman for my examples, but you can simply replace it with Docker if you prefer.

```bash
#Create the image
podman build -f ContainerFile --tag=zig_on_stm32:0.14.0 .
#Run a container
podman run --rm -it --privileged -v ./projects:/apps --name=zig_on_stm32 zig_on_stm32:0.14.0
# Navigate to a project (example blinky)
cd stm32l476_nucleo/blinky
```

Remove dangling image if needed `podman image prune`

**Debugging Trick with containers**

- TODO: Try to mount a container with same path host/containers


### Vs Code / Vs Codium

For `Vs Code` User, all project got à `.vscode` folder with à `launch.json` for debugging and à `tasks.json` to build and upload the firmware.
You can download theses extensions:

- `marus25.cortex-debug` for debugging ARM Cortex-M targets.

<img src="docs/images/vscode2.png" alt="drawing" width="80%"/>

- `actboy168.tasks` to got quick shortcut of your tasks in your status bar

<img src="docs/images/vscode3.png" alt="drawing" width="70%"/>

## SVD Files

The CMSIS System View Description format(CMSIS-SVD) formalizes the description of the system contained in Arm Cortex-M processor-based microcontrollers, in particular, the memory mapped registers of peripherals.

- You can use [regz](https://github.com/ZigEmbeddedGroup/microzig/tree/main/tools/regz) to generate `registers` code in Zig.
- You can use it with VS Code in debugging mode.

<img src="docs/images/vscode1.png" alt="drawing" width="50%"/>

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

## For STM32CubeMX generated linker script

Some requirements are needed to make it work with `lld` used by Zig.

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

## References

- [STM32 Guide](https://github.com/haydenridd/stm32-zig-porting-guide) will help you to understand and port your current project. Ziggit topic [here](https://ziggit.dev/t/stm32-porting-guide-first-pass/4414)
- This project may interest you: [Microzig](https://github.com/ZigEmbeddedGroup/microzig) A Unified abstraction layer and HAL for several microcontrollers
- [All Your Codebase](https://github.com/allyourcodebase) is an organization that package C/C++ projects for the Zig build system so that you can reliably compile (and cross-compile!) them with ease.