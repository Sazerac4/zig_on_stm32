const std = @import("std");
const c = @cImport({
    @cDefine("USE_HAL_DRIVER", {});
    @cDefine("STM32L476xx", {});
    @cDefine("__PROGRAM_START", ""); //Needed because of a bug: https://github.com/ziglang/zig/issues/19687
    @cInclude("main.h");
});

const os = @cImport({
    @cInclude("FreeRTOS.h");
    @cInclude("task.h");
    @cInclude("timers.h");
    @cInclude("queue.h");
});

export fn zig_task(params: ?*anyopaque) callconv(.C) void {
    _ = params;

    while (true) {
        c.HAL_GPIO_WritePin(c.LD2_GPIO_Port, c.LD2_Pin, c.GPIO_PIN_RESET);
        os.vTaskDelay(200);
        c.HAL_GPIO_WritePin(c.LD2_GPIO_Port, c.LD2_Pin, c.GPIO_PIN_SET);
        os.vTaskDelay(200);
    }
}

export fn zig_entrypoint() void {

    // Temporary task to initialize the system
    const pvParameters: ?*anyopaque = null;
    const pxCreatedTask: ?*os.TaskHandle_t = null;
    _ = os.xTaskCreate(zig_task, "Blinky", 256, pvParameters, 15, pxCreatedTask);
    // Start application
    os.vTaskStartScheduler();

    unreachable;
}
