//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const a_input = "test";
    const a_key_pub = "123";
    const a_key_priv = "321";
    const b_key_pub = "abc";
    const b_key_priv = "cba";

    var intermediate = xor_str(a_input, a_key_priv);
    try stdout.print("{any}\n", .{intermediate});
    intermediate = xor_str(intermediate, a_key_pub);
    try stdout.print("{any}\n", .{intermediate});
    intermediate = xor_str(intermediate, b_key_pub);
    try stdout.print("sent over wire from a to b: {any}\n", .{intermediate});
    intermediate = xor_str(intermediate, b_key_priv);
    try stdout.print("{any}\n", .{intermediate});
    intermediate = xor_str(intermediate, b_key_priv);
    try stdout.print("sent over wire from b to a: {any}\n", .{intermediate});
    intermediate = xor_str(intermediate, a_key_priv);
    try stdout.print("{any}\n", .{intermediate});
    intermediate = xor_str(intermediate, a_key_pub);
    try stdout.print("sent over wire from a to b: {any}\n", .{intermediate});
    intermediate = xor_str(intermediate, b_key_priv);
    try stdout.print("{any}\n", .{intermediate});
    intermediate = xor_str(intermediate, b_key_pub);
    try stdout.print("should be original at b: {any}\n", .{intermediate});

    try bw.flush(); // Don't forget to flush!
}

pub fn xor_str(a: []const u8, b: []const u8) []u8 {
    var res: [128]u8 = .{0} ** 128;
    for (0..a.len) |i| {
        var b_index = i;
        while (b_index >= b.len) {
            b_index = b_index - b.len;
        }
        res[i] = a[i] ^ b[b_index];
    }
    return res[0..a.len];
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("tcp_server_lib");
