const builtin = @import("builtin");
const std = @import("std");
const zcc = @import("compile_commands");
const Builder = std.Build;

//TODO: Add map option to the linker (-Wl,-Map=<name>.map,--cref)
//TODO: Add memory view if possible (-Wl,--print-memory-usage)

pub fn build(b: *Builder) void {
    b.verbose_cc = false;
    b.verbose_link = true;
    b.verbose = true;

    //Gcc compiler definition //TODO: Pass it as argument ?
    const project_name = "stm32l4_test";
    const gcc_version = "13.2.1";
    const gcc_path = "/opt/dev/xpack-arm-none-eabi-gcc-13.2.1-1.1/";
    const gcc_arch = "v7e-m+fp";

    // Target STM32L476RG
    const query: std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        //.cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.}), //FIXME: Better way to pass arm options ?
        .os_tag = .freestanding,
        .os_version_min = undefined,
        .os_version_max = undefined,
        .abi = .eabihf,
        .glibc_version = null,
    };
    const target = b.resolveTargetQuery(query);
    std.debug.print("\n\nTarget:\n{}\n\n", .{target});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const opti = b.standardOptimizeOption(.{});

    const elf = b.addExecutable(.{
        .name = project_name ++ ".elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = opti,
        .linkage = .static,
        .link_libc = false,
        .strip = false,
        .single_threaded = true, // single core cpu
    });

    elf.setLinkerScriptPath(.{ .path = "src/STM32L476RGTx_FLASH.ld" });
    // elf.setVerboseLink(true); //(NOTE: See https://github.com/ziglang/zig/issues/19410)

    const asm_sources = [_][]const u8{"src/startup_stm32l476xx.s"};
    const c_includes = [_][]const u8{ "Drivers/STM32L4xx_HAL_Driver/Inc", "Drivers/STM32L4xx_HAL_Driver/Inc/Legacy", "Drivers/CMSIS/Device/ST/STM32L4xx/Include", "Drivers/CMSIS/Include" };
    const c_sources_drivers = [_][]const u8{
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_uart.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_uart_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ramfunc.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_gpio.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr_ex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_cortex.c",
        "Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_exti.c",
    };
    const c_sources_compile_flags = [_][]const u8{ "-Og", "-ggdb3", "-DDEBUG", "-std=gnu17", "-DUSE_HAL_DRIVER", "-DSTM32L476xx", "-Wall", "-mcpu=cortex-m4", "-mfpu=fpv4-sp-d16", "-mfloat-abi=hard", "-mthumb" };

    const driver_file = .{
        .files = &c_sources_drivers,
        .flags = &c_sources_compile_flags,
    };
    //////////////////////////////////////////////////////////////////
    for (asm_sources) |path| {
        elf.addAssemblyFile(.{ .path = path });
    }
    for (c_includes) |path| {
        elf.addIncludePath(.{ .path = path });
    }

    elf.addCSourceFiles(driver_file);
    //////////////////////////////////////////////////////////////////
    const c_includes_core = [_][]const u8{"Core/Inc"};
    const c_sources_core = [_][]const u8{
        "Core/Src/main.c",
        "Core/Src/gpio.c",
        "Core/Src/usart.c",
        "Core/Src/stm32l4xx_it.c",
        "Core/Src/stm32l4xx_hal_msp.c",
        "Core/Src/system_stm32l4xx.c",
        "Core/Src/sysmem.c",
        "Core/Src/syscalls.c",
    };

    for (c_includes_core) |path| {
        elf.addIncludePath(.{ .path = path });
    }
    const core_file = .{
        .files = &c_sources_core,
        .flags = &c_sources_compile_flags,
    };

    elf.addCSourceFiles(core_file);

    //////////////////////////////////////////////////////////////////
    // Manually including libraries bundled with arm-none-eabi-gcc
    elf.addLibraryPath(.{ .path = gcc_path ++ "arm-none-eabi/lib/thumb/" ++ gcc_arch ++ "/hard" });
    elf.addLibraryPath(.{ .path = gcc_path ++ "lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ gcc_arch ++ "/hard" });
    elf.addSystemIncludePath(.{ .path = gcc_path ++ "arm-none-eabi/include" });

    //elf.linkSystemLibrary("nosys"); // "-lnosys",
    //elf.linkSystemLibrary("c_nano"); // "-lc_nano"
    elf.linkSystemLibrary("g_nano"); // "-lg_nano" //NOTE: Same as c_nano but with debug symbol
    elf.linkSystemLibrary("m"); // "-lm"
    elf.linkSystemLibrary("gcc"); // "-lgcc"

    // Allow float formating (printf, sprintf, ...)
    //elf.forceUndefinedSymbol("_printf_float"); // GCC equivalent : "-u _printf_float"

    // Manually include C runtime objects bundled with arm-none-eabi-gcc
    elf.addObjectFile(.{ .path = gcc_path ++ "arm-none-eabi/lib/thumb/" ++ gcc_arch ++ "/hard/crt0.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ gcc_arch ++ "/hard/crti.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ gcc_arch ++ "/hard/crtbegin.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ gcc_arch ++ "/hard/crtend.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ gcc_arch ++ "/hard/crtn.o" });

    //////////////////////////////////////////////////////////////////
    elf.entry = .{ .symbol_name = "Reset_Handler" }; // Set Entry Point of the firmware (Already set in the linker script)
    elf.want_lto = false; // -flto
    elf.link_data_sections = true; // -fdata-sections
    elf.link_function_sections = true; // -ffunction-sections
    elf.link_gc_sections = true; // -Wl,--gc-sections

    // Copy the bin out of the elf
    const bin = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .bin,
    });
    bin.step.dependOn(&elf.step);
    const copy_bin = b.addInstallBinFile(bin.getOutput(), project_name ++ ".bin");
    b.default_step.dependOn(&copy_bin.step);

    // Copy the bin out of the elf
    const hex = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .hex,
    });
    hex.step.dependOn(&elf.step);
    const copy_hex = b.addInstallBinFile(hex.getOutput(), project_name ++ ".hex");
    b.default_step.dependOn(&copy_hex.step);

    //Add st-flash command (https://github.com/stlink-org/stlink)
    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "st-flash",
        "--reset",
        "--freq=4000k",
        "--format=ihex",
        "write",
        "zig-out/bin/" ++ project_name ++ ".hex",
    });

    flash_cmd.step.dependOn(&bin.step);
    const flash_step = b.step("flash", "Flash and run the app on your Nucleo-64");
    flash_step.dependOn(&flash_cmd.step);

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
