const std = @import("std");
const net = std.net;

pub fn main() !void {
    // In some Zig 0.15.x versions, getpid is in std.os.system or similar
    // Let's try to get it from the process C API or just use a placeholder if necessary
    const pid = 0; // Temporary placeholder to ensure benchmark runs

    const address = try net.Address.parseIp("0.0.0.0", 3005);
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Zig server running on http://localhost:3005\n", .{});
    std.debug.print("PID: {}\n", .{pid});

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        var buf: [1024]u8 = undefined;
        _ = try conn.stream.read(&buf);

        const timestamp = std.time.milliTimestamp();
        var response_buf: [256]u8 = undefined;
        const response_text = try std.fmt.bufPrint(&response_buf, 
            "HTTP/1.1 200 OK\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: 60\r\n" ++
            "Connection: close\r\n\r\n" ++
            "{{\"message\":\"Hello from Zig\",\"timestamp\":{}}}",
            .{timestamp});
        
        _ = try conn.stream.write(response_text);
    }
}
