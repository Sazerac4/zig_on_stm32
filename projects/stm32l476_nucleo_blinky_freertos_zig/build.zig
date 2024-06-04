const builtin = @import("builtin");
const std = @import("std");
const zcc = @import("compile_commands");
const Builder = std.Build;

//TODO: Add map option to the linker (-Wl,-Map=<name>.map,--cref)
//TODO: Add memory view if possible (-Wl,--print-memory-usage)

pub fn build(b: *Builder) void {

    //Gcc compiler definition //TODO: Pass it as argument ?
    //const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
    const project_name = "blinky_freertos_zig";

    //GCC
    const gcc_version = "13.2.1";
    const gcc_path = "/opt/dev/xpack-arm-none-eabi-gcc-13.2.1-1.1/";
    //soft   => v7e-m/nofp
    //softfp => v7e-m+fp/softfp
    //hard   => v7e-m+fp/hard
    const float_abi_opt = "v7e-m+fp/hard"; //(-mfloat-abi=<select>)

    // Target STM32L476RG
    const query: std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        //.cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.}), //FIXME: What is the ARM features to pass for STM32L4 ?
        .os_tag = .freestanding,
        .os_version_min = undefined,
        .os_version_max = undefined,
        .abi = .eabihf,
        .glibc_version = null,
    };
    const target = b.resolveTargetQuery(query);

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

    const asm_sources = [_][]const u8{"src/startup_stm32l476xx.s"};
    for (asm_sources) |path| {
        elf.addAssemblyFile(.{ .path = path });
    }

    const c_sources_compile_flags = [_][]const u8{ "-Og", "-ggdb3", "-gdwarf-2", "-std=gnu17", "-DUSE_HAL_DRIVER", "-DSTM32L476xx", "-Wall", "-mfloat-abi=hard", "-mfpu=fpv4-sp-d16" };

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
    elf.addCSourceFiles(.{
        .files = &c_sources_drivers,
        .flags = &c_sources_compile_flags,
    });

    //////////////////////////////////////////////////////////////////
    const c_includes = [_][]const u8{ "Drivers/STM32L4xx_HAL_Driver/Inc", "Drivers/STM32L4xx_HAL_Driver/Inc/Legacy", "Drivers/CMSIS/Device/ST/STM32L4xx/Include", "Drivers/CMSIS/Include" };
    for (c_includes) |path| {
        elf.addIncludePath(.{ .path = path });
    }

    //////////////////////////////////////////////////////////////////
    const c_sources_core = [_][]const u8{
        "Core/Src/main.c",
        "Core/Src/gpio.c",
        "Core/Src/usart.c",
        "Core/Src/stm32l4xx_hal_timebase_tim.c",
        "Core/Src/freertos.c",
        "Core/Src/stm32l4xx_it.c",
        "Core/Src/stm32l4xx_hal_msp.c",
        "Core/Src/system_stm32l4xx.c",
        "Core/Src/sysmem.c",
        "Core/Src/syscalls.c",
    };
    elf.addCSourceFiles(.{
        .files = &c_sources_core,
        .flags = &c_sources_compile_flags,
    });

    const c_includes_core = [_][]const u8{"Core/Inc"};
    for (c_includes_core) |path| {
        elf.addIncludePath(.{ .path = path });
    }

    //////////////////////////////////////////////////////////////////
    // FreeRTOS source code
    const c_includes_os = [_][]const u8{ "Middlewares/Third_Party/FreeRTOS/Source/include", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2", "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F" };
    for (c_includes_os) |path| {
        elf.addIncludePath(.{ .path = path });
    }

    elf.addObjectFile(.{ .path = "library/libfreertos.a" }); //FIXME: good way to include .a ?

    const c_sources_os = [_][]const u8{
        // "Middlewares/Third_Party/FreeRTOS/Source/croutine.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/event_groups.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/list.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/queue.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/stream_buffer.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/tasks.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/timers.c",
        "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2/cmsis_os2.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c",
        // "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c",
    };
    elf.addCSourceFiles(.{
        .files = &c_sources_os,
        .flags = &c_sources_compile_flags,
    });

    //////////////////////////////////////////////////////////////////
    // Manually including libraries bundled with arm-none-eabi-gcc
    elf.addLibraryPath(.{ .path = gcc_path ++ "arm-none-eabi/lib/thumb/" ++ float_abi_opt });
    elf.addLibraryPath(.{ .path = gcc_path ++ "lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ float_abi_opt });
    elf.addSystemIncludePath(.{ .path = gcc_path ++ "arm-none-eabi/include" });

    //elf.linkSystemLibrary("nosys"); // "-lnosys",
    //elf.linkSystemLibrary("c_nano"); // "-lc_nano"
    elf.linkSystemLibrary("g_nano"); // "-lg_nano" //NOTE: Same as c_nano but with debug symbol
    elf.linkSystemLibrary("m"); // "-lm"
    elf.linkSystemLibrary("gcc"); // "-lgcc"

    // Allow float formating (printf, sprintf, ...)
    // elf.forceUndefinedSymbol("_printf_float"); // GCC equivalent : "-u _printf_float"

    // Manually include C runtime objects bundled with arm-none-eabi-gcc
    elf.addObjectFile(.{ .path = gcc_path ++ "arm-none-eabi/lib/thumb/" ++ float_abi_opt ++ "/crt0.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ float_abi_opt ++ "/crti.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ float_abi_opt ++ "/crtbegin.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ float_abi_opt ++ "/crtend.o" });
    elf.addObjectFile(.{ .path = gcc_path ++ "/lib/gcc/arm-none-eabi/" ++ gcc_version ++ "/thumb/" ++ float_abi_opt ++ "/crtn.o" });

    // Tell to zig that libc is linked now
    //elf.is_linking_libc = true;

    //////////////////////////////////////////////////////////////////
    elf.setLinkerScriptPath(.{ .path = "src/STM32L476RGTx_FLASH.ld" });
    // elf.setVerboseCC(true);
    // elf.setVerboseLink(true); //(NOTE: See https://github.com/ziglang/zig/issues/19410)
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

    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(b.install_path).step);
    if (builtin.os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("zig-cache")).step);
    }

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
