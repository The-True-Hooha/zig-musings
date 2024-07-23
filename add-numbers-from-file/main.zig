// read a file and sum up the numbers in it
const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello world\n", .{});

    const filename = "num.txt";
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 1024 * 1024);

    defer allocator.free(file_contents); // reomve the read contents from the allocator

    // try std.io.getStdOut().writeAll(file_contents); // prints the read file

    var ready_by_line = std.mem.tokenizeScalar(u8, file_contents, '\n');

    var arr = std.ArrayList(u32).init(allocator);
    defer arr.deinit();

    var hold: u32 = 0;

    while (ready_by_line.next()) |amount| {
        // std.debug.print("{s}\n", .{amount});
        const trim_spaces = std.mem.trim(u8, amount, &std.ascii.whitespace);
        if (trim_spaces.len == 0) {
            try arr.append(hold);
            hold = 0;
            // std.debug.print("{}\n", .{result});
        } else {
            const result: u32 = std.fmt.parseInt(u32, trim_spaces, 10) catch |err| {
                std.debug.print("an error passing the line : '{s}': {}\n", .{ trim_spaces, err });
                continue;
            };
            hold += result;
        }
    }

    // append the last group if empty
    if (hold > 0) {
        try arr.append(hold);
    }
    if (arr.items.len > 0) {
        const max_num = std.mem.max(u32, arr.items);
        std.debug.print("Max number {}", .{max_num});

        std.debug.print(" all groups sums: \n", .{});
        for (arr.items, 0..) |item, index| {
            std.debug.print("group {}: {}\n", .{ index + 1, item });
        }
    }else {
        std.debug.print("No other groups found in the file\n", .{});
    }

    // for (arr.items) |item| {
    //     std.debug.print("item: {}", .{item});
    // }
}
