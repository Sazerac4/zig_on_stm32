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
    └── blinky_freertos/
```

## Installation

**Tools:**

- zig : `0.14.0` minimum
- STM32CubeMX : `6.13.0` minimum
- arm-none-eabi-gcc : `14.2.1` used
- stlink-tools : `v1.8.0` used
- openocd : `v0.12.0` used
- cmake : `3.30.5` used

### Linux

```bash
#Fedora
yum install cmake make wget stlink openocd
#Debian
apt install cmake make wget stlink-tools openocd xz-utils

#Create folder softs
mkdir -vp /opt/softs

#Install arm-none-eabi-gcc
GCC_VERSION="14.2.1-1.1"
cd /tmp && wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v${GCC_VERSION}/xpack-arm-none-eabi-gcc-${GCC_VERSION}-linux-x64.tar.gz \
    && tar -xf /tmp/xpack-arm-none-eabi-gcc-*-linux-x64.tar.gz -C /opt/softs/ \
    && ln -s /opt/softs/xpack-arm-none-eabi-gcc-*/bin/arm-none-eabi-*  ~/.local/bin

#Install zig
ZIG_VERSION="0.14.0-dev.2851+b074fb7dd"
cd /tmp && wget https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
    tar -xf /tmp/zig-linux-x86_64-*.tar.xz -C /opt/softs/ && \
    ln -s /opt/softs/zig-linux-x86_64-*/zig ~/.local/bin
```

### Windows

1. Create a `softs` folder (example : `C:\softs` )
2. Download [zig](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.2851+b074fb7dd.zip)
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
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0-dev.2851+b074fb7dd;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\softs\xpack-openocd-0.12.0-4\bin",
   "User"
)
```

### Containers (Podman or Docker)

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

## Reference:

- [STM32 Guide](https://github.com/haydenridd/stm32-zig-porting-guide) will help you to understand and port your current project. Ziggit topic [here](https://ziggit.dev/t/stm32-porting-guide-first-pass/4414)
- This project may interest you: [Microzig](https://github.com/ZigEmbeddedGroup/microzig) A Unified abstraction layer and HAL for several microcontrollers
- FreeRTOS discussion on [ziggit.dev](https://ziggit.dev/t/exploring-zig-on-stm32-with-freertos/4653)