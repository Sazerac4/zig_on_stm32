const std = @import("std");

// export fn SystemInit() void {}

export fn main_zig() void {
    //std.time.sleep(100);
    var i: u8 = 10;
    while (true) {
        i += 1;
        if (i == 100) {
            break;
        }
    }

    var a = [_]usize{ 0, 1, 2, 3 };
    var b = [_]usize{ 2, 3, 4, 5 };

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.

    for (&a, &b, 0..) |*val1, *val2, index| {
        //try stdout.print("Run `zig build test` to run the tests: {any},{any},{any}\n", .{ val1.*, val2.*, index });
        _ = val1.*;
        val2.* = index;
    }

    const val = simple_calcul(5, 5) catch 5;
    if (val == 5) {
        main_zig();
    }
}

fn simple_calcul(a: u8, b: u8) !u8 {
    if (a >= b) {
        return error.InvalidNumber;
    }
    const c = a + b;
    return c;
}
