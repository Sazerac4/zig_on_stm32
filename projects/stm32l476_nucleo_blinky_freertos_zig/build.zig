const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) void {

    //const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
    const executable_name = "blinky_freertos_zig";

    // Target STM32L476RG
    const query: std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.vfp4d16sp}),
        .os_tag = .freestanding,
        .abi = .eabihf,
        .glibc_version = null,
    };
    const target = b.resolveTargetQuery(query);

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const opti = b.standardOptimizeOption(.{});

    const elf = b.addExecutable(.{
        .name = executable_name ++ ".elf",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = opti,
        .linkage = .static,
        .link_libc = false,
        .strip = false,
        .single_threaded = true, // single core cpu
    });

    //////////////////////////////////////////////////////////////////
    // User Options
    // Try to find arm-none-eabi-gcc program at a user specified path, or PATH variable if none provided
    const arm_gcc_pgm = if (b.option([]const u8, "ARM_GCC_PATH", "Path to arm-none-eabi-gcc compiler")) |arm_gcc_path|
        b.findProgram(&.{"arm-none-eabi-gcc"}, &.{arm_gcc_path}) catch {
            std.log.err("Couldn't find arm-none-eabi-gcc at provided path: {s}\n", .{arm_gcc_path});
            unreachable;
        }
    else
        b.findProgram(&.{"arm-none-eabi-gcc"}, &.{}) catch {
            std.log.err("Couldn't find arm-none-eabi-gcc in PATH, try manually providing the path to this executable with -Darmgcc=[path]\n", .{});
            unreachable;
        };

    // Allow user to enable float formatting in newlib (printf, sprintf, ...)
    if (b.option(bool, "NEWLIB_PRINTF_FLOAT", "Force newlib to include float support for printf()")) |_| {
        elf.forceUndefinedSymbol("_printf_float"); // GCC equivalent : "-u _printf_float"
    }
    //////////////////////////////////////////////////////////////////

    const asm_sources = [_][]const u8{"src/startup_stm32l476xx.s"};
    for (asm_sources) |path| {
        elf.addAssemblyFile(b.path(path));
    }

    const c_sources_compile_flags = [_][]const u8{ "-Og", "-ggdb3", "-gdwarf-2", "-std=gnu17", "-DUSE_HAL_DRIVER", "-DSTM32L476xx", "-Wall" };

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
        elf.addIncludePath(b.path(path));
    }

    //////////////////////////////////////////////////////////////////
    const c_sources_core = [_][]const u8{ "Core/Src/main.c", "Core/Src/gpio.c", "Core/Src/usart.c", "Core/Src/stm32l4xx_hal_timebase_tim.c", "Core/Src/freertos.c", "Core/Src/stm32l4xx_it.c", "Core/Src/stm32l4xx_hal_msp.c", "Core/Src/system_stm32l4xx.c", "Core/Src/sysmem.c", "Core/Src/syscalls.c", "Core/Src/freertos-openocd.c" };
    elf.addCSourceFiles(.{
        .files = &c_sources_core,
        .flags = &c_sources_compile_flags,
    });

    const c_includes_core = [_][]const u8{"Core/Inc"};
    for (c_includes_core) |path| {
        elf.addIncludePath(b.path(path));
    }

    //////////////////////////////////////////////////////////////////
    // FreeRTOS source code
    const c_includes_os = [_][]const u8{ "Middlewares/Third_Party/FreeRTOS/Source/include", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2", "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F" };
    for (c_includes_os) |path| {
        elf.addIncludePath(b.path(path));
    }

    const c_sources_os = [_][]const u8{
        "Middlewares/Third_Party/FreeRTOS/Source/croutine.c",
        "Middlewares/Third_Party/FreeRTOS/Source/event_groups.c",
        "Middlewares/Third_Party/FreeRTOS/Source/list.c",
        "Middlewares/Third_Party/FreeRTOS/Source/queue.c",
        "Middlewares/Third_Party/FreeRTOS/Source/stream_buffer.c",
        "Middlewares/Third_Party/FreeRTOS/Source/tasks.c",
        "Middlewares/Third_Party/FreeRTOS/Source/timers.c",
        "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2/cmsis_os2.c",
        "Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c",
        "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c",
    };
    elf.addCSourceFiles(.{
        .files = &c_sources_os,
        .flags = &c_sources_compile_flags,
    });

    // Used when debugging with gdb/openocd
    elf.forceUndefinedSymbol("uxTopUsedPriority");

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //  Use gcc-arm-none-eabi to figure out where library paths are
    const gcc_arm_sysroot_path = std.mem.trim(u8, b.run(&.{ arm_gcc_pgm, "-print-sysroot" }), "\r\n");
    const gcc_arm_multidir_relative_path = std.mem.trim(u8, b.run(&.{ arm_gcc_pgm, "-mcpu=cortex-m4", "-mfpu=fpv4-sp-d16", "-mfloat-abi=hard", "-print-multi-directory" }), "\r\n");
    const gcc_arm_version = std.mem.trim(u8, b.run(&.{ arm_gcc_pgm, "-dumpversion" }), "\r\n");
    const gcc_arm_lib_path1 = b.fmt("{s}/../lib/gcc/arm-none-eabi/{s}/{s}", .{ gcc_arm_sysroot_path, gcc_arm_version, gcc_arm_multidir_relative_path });
    const gcc_arm_lib_path2 = b.fmt("{s}/lib/{s}", .{ gcc_arm_sysroot_path, gcc_arm_multidir_relative_path });

    // Manually add "nano" variant newlib C standard lib from arm-none-eabi-gcc library folders
    elf.addLibraryPath(.{ .cwd_relative = gcc_arm_lib_path1 });
    elf.addLibraryPath(.{ .cwd_relative = gcc_arm_lib_path2 });
    elf.addSystemIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{gcc_arm_sysroot_path}) });
    elf.linkSystemLibrary("c_nano"); // Use "g_nano" ?
    elf.linkSystemLibrary("m");

    // Manually include C runtime objects bundled with arm-none-eabi-gcc
    elf.addObjectFile(.{ .cwd_relative = b.fmt("{s}/crt0.o", .{gcc_arm_lib_path2}) });
    elf.addObjectFile(.{ .cwd_relative = b.fmt("{s}/crti.o", .{gcc_arm_lib_path1}) });
    elf.addObjectFile(.{ .cwd_relative = b.fmt("{s}/crtbegin.o", .{gcc_arm_lib_path1}) });
    elf.addObjectFile(.{ .cwd_relative = b.fmt("{s}/crtend.o", .{gcc_arm_lib_path1}) });
    elf.addObjectFile(.{ .cwd_relative = b.fmt("{s}/crtn.o", .{gcc_arm_lib_path1}) });

    // Tell to zig that libc is linked now
    //elf.is_linking_libc = true;

    //////////////////////////////////////////////////////////////////
    elf.setLinkerScriptPath(b.path("src/STM32L476RGTx_FLASH.ld"));
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
    const copy_bin = b.addInstallBinFile(bin.getOutput(), executable_name ++ ".bin");
    b.default_step.dependOn(&copy_bin.step);

    // Copy the bin out of the elf
    const hex = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .hex,
    });
    hex.step.dependOn(&elf.step);
    const copy_hex = b.addInstallBinFile(hex.getOutput(), executable_name ++ ".hex");
    b.default_step.dependOn(&copy_hex.step);

    //Add st-flash command (https://github.com/stlink-org/stlink)
    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "st-flash",
        "--reset",
        "--freq=4000k",
        "--format=ihex",
        "write",
        "zig-out/bin/" ++ executable_name ++ ".hex",
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
