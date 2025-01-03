const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.debug.print("Usage: {s} <password_length>\n", .{args[0]});
        return;
    }

    const length = try std.fmt.parseInt(usize, args[1], 10);
    const password = try generatePassword(allocator, length);
    defer allocator.free(password);

    std.debug.print("Generated password: {s}\n", .{password});
}

fn generatePassword(allocator: std.mem.Allocator, length: usize) ![]u8 {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+";
    const password = try allocator.alloc(u8, length);

    // Use crypto.random instead of DefaultPrng
    const random = std.crypto.random;

    for (password) |*c| {
        c.* = charset[random.uintLessThan(u8, charset.len)];
    }

    return password;
}
