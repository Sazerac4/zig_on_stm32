const builtin = @import("builtin");
const std = @import("std");
const zcc = @import("compile_commands");
const Builder = std.Build;

pub fn build(b: *Builder) void {
    b.verbose_cc = false;
    b.verbose_link = true;
    b.verbose = true;

    // Target STM32L476RG
    const query: std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
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
        .name = "stm32l4.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = opti,
        .linkage = .static,
        .link_libc = false,
        .strip = false,
        .single_threaded = true, // single core cpu
    });

    elf.setLinkerScriptPath(.{ .path = "src/STM32L476RGTx_FLASH.ld" });
    elf.setVerboseLink(true);

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
    const c_sources_compile_flags = [_][]const u8{ "-std=gnu17", "-DUSE_HAL_DRIVER", "-DSTM32L476xx", "-Wall", "-fdata-sections", "-ffunction-sections", "-mcpu=cortex-m4", "-mfpu=fpv4-sp-d16", "-mfloat-abi=hard", "-mthumb", "-lnosys", "--specs=nano.specs", "-Wl,--gc-sections" };

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
        //"Core/Src/sysmem.c",
        //"Core/Src/syscalls.c",
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
    // make a list of targets that have include files and c source files
    //var targets = std.ArrayList(*std.Build.CompileStep).init(b.allocator);
    //targets.append(elf) catch @panic("OOM");
    //zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));

    //////////////////////////////////////////////////////////////////
    //TODO: lib c linker option -Wl,--gc-sections -specs=nano.specs  // -lnosys
    //setLibCFile better choice ?
    // const arm_none_eabi_path = "/opt/dev/xpack-arm-none-eabi-gcc-12.3.1-1.2/arm-none-eabi/";
    // elf.addObjectFile(.{ .path = arm_none_eabi_path ++ "lib/thumb/v7e-m+dp/hard/libc.a" });
    // elf.addObjectFile(.{ .path = arm_none_eabi_path ++ "lib/thumb/v7e-m+fp/hard/libnosys.a" });
    // elf.addObjectFile(.{ .path = arm_none_eabi_path ++ "lib/thumb/v7e-m+fp/hard/libc_nano.a" });
    // elf.addObjectFile(.{ .path = arm_none_eabi_path ++ "lib/thumb/v7e-m+fp/hard/libm.a" });
    // elf.addSystemIncludePath(.{ .path = arm_none_eabi_path ++ "include/" });

    // Set Entry Point of the firmware (Already set in the linker script)
    elf.entry = .{ .symbol_name = "Reset_Handler" };
    elf.want_lto = false;

    // Copy the elf to the output directory.
    const copy_elf = b.addInstallArtifact(elf, .{});
    b.default_step.dependOn(&copy_elf.step);

    // Copy the bin out of the elf
    const bin = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .bin,
    });
    bin.step.dependOn(&elf.step);

    // Copy the bin out of the elf
    const hex = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .hex,
    });
    hex.step.dependOn(&elf.step);

    // Copy the bin to the output directory
    const copy_bin = b.addInstallBinFile(bin.getOutput(), "stm32l4.bin");
    b.default_step.dependOn(&copy_bin.step);
    const copy_hex = b.addInstallBinFile(hex.getOutput(), "stm32l4.hex");
    b.default_step.dependOn(&copy_hex.step);

    //TODO: Add map option to the linker
    //TODO: Add memory view if possible
    // const bin_step = b.step("bin", "Generate binary file to be flashed");
    // bin_step.dependOn(&bin.step);

    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "st-flash",
        "--reset",
        "--freq=4000k",
        "write",
        "zig-out/bin/stm32l4.hex",
    });
    flash_cmd.step.dependOn(&bin.step);
    const flash_step = b.step("flash", "Flash and run the app on your Nucleo-64");
    flash_step.dependOn(&flash_cmd.step);

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
