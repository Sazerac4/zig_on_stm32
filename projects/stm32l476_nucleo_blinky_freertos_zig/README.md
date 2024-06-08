## Build

```bash
# Build
zig build
# Upload using stlink-tools
zig build flash
```

## Options

```bash
# Enable Float formatting
zig build -DNEWLIB_PRINTF_FLOAT
# Add Custom GCCPATH
zig build -DARM_GCC_PATH=<path>
```

## Execution

The zig code starts at the `zig_entrypoint` function which is called from the `main` function which is located in the `Core/Src/main.c` file.  
The `Core`, `Drivers` and `Middlewares` folders were generated by `STM32CubeMX` software.