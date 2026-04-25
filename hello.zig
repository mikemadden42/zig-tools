const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = stdout.writer(init.io, &buf);
    try writer.interface.print("Hello, {s}!\n", .{"world"});
    try writer.interface.flush();
}
