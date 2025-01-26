## Context

Are you considering incorporating Zig code into your embedded development projects, specifically on STM32 or other similar platforms?  
If so, I'd like to share some demo examples that demonstrate how to  integrate Zig code into your projects.  
These examples utilize the STM32CubeMX code generator as well as the drivers provided by ST, which are probably already integrated into your projects and which you want to keep.


## Example

Each example of a C project below has its Zig equivalent ending with `_zig`

- stm32l476_nucleo_blinky
- stm32l476_nucleo_blinky_freertos

## Installation

**tools:**

- arm-none-eabi-gcc : 13.2.1
- zig :  0.14.0
- STM32CubeMX : 6.13.0
- stlink-tools : v1.8.0
- openocd : 0.12.0

### Linux


### Windows


## Build

### Build

- See each project to see how to build

### Build with containers (podman/docker)

You can build all firmware by with the image from ContainerFile

```bash
#Create the image
podman build -f ContainerFile --tag=zig_projects/build .
#Run a container
podman run --rm -it --privileged -v ./:/projects --name=zig_projects zig_projects/build
# Build a project
cd  /projects/<name>/
...
```

```bash
#Remove all images and containers
podman system prune --all --force && podman rmi --all
```

### Flash with containers

```bash
# Add dialout group to user (for Serial communication)
sudo usermod -a -G dialout $USER
```

## Reference:

- [STM32 Guide](https://github.com/Sazerac4/stm32-zig-porting-guide/tree/main) will help you to understand and port your current project. Ziggit topic [here](https://ziggit.dev/t/stm32-porting-guide-first-pass/4414)
- This project may interest you: [Microzig](https://github.com/ZigEmbeddedGroup/microzig) A Unified abstraction layer and HAL for several microcontrollers
- FreeRTOS discussion on [ziggit](https://ziggit.dev/t/exploring-zig-on-stm32-with-freertos/4653)