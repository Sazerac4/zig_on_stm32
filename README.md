## Context

Are you considering incorporating Zig code into your embedded development projects, specifically on STM32 or other similar platforms?  
If so, I'd like to share some demo examples that demonstrate how to  integrate Zig code into your projects.  
These examples utilize the STM32CubeMX code generator as well as the drivers provided by ST, which are probably already integrated into your projects and which you want to keep.

## Installation

**Tools:**

- arm-none-eabi-gcc : 14.2.1
- zig :  0.14.0
- STM32CubeMX : 6.13.0
- stlink-tools : v1.8.0

### Linux

```bash
#Fedora
yum install wget stlink
#Debian
apt install wget stlink-tools xz-utils

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

- Create a `softs` folder (example : `C:\softs` )
- Download [zig](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.2851+b074fb7dd.zip)
- Download [arm-none-eabi-gcc](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v14.2.1-1.1)
- Download [stlink](https://github.com/stlink-org/stlink/releases/tag/v1.8.0)
- Extract everything to the folder `softs`

**Setup environnement variables**

Here, the command to setup environnement variable according to the instructions below.
You need to choice between System wide or User level.

- System wide (admin Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin",
   "Machine"
)
```
- User level (Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\softs\stlink-1.8.0-win32\bin;C:\softs\zig-windows-x86_64-0.14.0-dev.2851+b074fb7dd;C:\softs\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin",
   "User"
)
```

### Containers (Podman or Docker)

```bash
#Create the image
podman build -f ContainerFile --tag=zig_on_stm32:0.14.0 .
#Run a container
podman run --rm -it --privileged -v ./projects:/apps --name=zig_projects zig_on_stm32
# Navigate to a project (example blinky)
cd stm32l476_nucleo/blinky
```

Remove dangling image if needed : `podman image prune`

## Build

Each program has a C and Zig implementation in the same project.
To use the C implementation, type the command: `zig build -DNO_ZIG`

```
projects/
└── stm32l476_nucleo/
    ├── blinky/
    └── blinky_freertos/
```

- See the `README.md` for each project for specific options and instructions

## Reference:

- [STM32 Guide](https://github.com/haydenridd/stm32-zig-porting-guide) will help you to understand and port your current project. Ziggit topic [here](https://ziggit.dev/t/stm32-porting-guide-first-pass/4414)
- This project may interest you: [Microzig](https://github.com/ZigEmbeddedGroup/microzig) A Unified abstraction layer and HAL for several microcontrollers
- FreeRTOS discussion on [ziggit.dev](https://ziggit.dev/t/exploring-zig-on-stm32-with-freertos/4653)