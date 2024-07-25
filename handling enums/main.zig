const std = @import("std");

const Moves = enum {
    rock,
    paper,
    scissors,
};

const Result = enum {
    win,
    draw,
    loss,
};
const throw_error = error{UnrecognizedInput};

pub fn handleMoveExec(input: u8) throw_error!Moves {
    const result: throw_error!Moves = switch (input) {
        'X' => .rock,
        'Y' => Moves.paper,
        'Z' => Moves.scissors,
        else => throw_error.UnrecognizedInput,
    };
    return result;
}

fn handleOtherMoveExec(input: u8) throw_error!Moves {
    const result: throw_error!Moves = switch (input) {
        'A' => Moves.rock,
        'B' => Moves.paper,
        'C' => Moves.scissors,
        else => throw_error.UnrecognizedInput,
    };
    return result;
}

fn computeResult(first: Moves, second: Moves) Result {
    const result: Result = switch (first) {
        .rock => switch (second) {
            .rock => Result.draw,
            .paper => Result.loss,
            .scissors => Result.win,
        },
        .paper => switch (second) {
            Moves.paper => Result.draw,
            Moves.rock => Result.win,
            Moves.scissors => Result.loss,
        },
        .scissors => switch (second) {
            Moves.scissors => Result.draw,
            Moves.paper => Result.win,
            Moves.rock => Result.loss,
        },
    };
    return result;
}

fn getMoveScore(move: Moves) i32 {
    const result: i32 = switch (move) {
        .paper => 2,
        .rock => 1,
        .scissors => 3,
    };

    return result;
}

fn getResultScore(result: Result) i32 {
    const score: i32 = switch (result) {
        .draw => 3,
        .loss => 0,
        .win => 6,
    };

    return score;
}

fn calcTotalScore(move: Moves, result: Result) i32 {
    const move_score = getMoveScore(move);
    const result_score = getResultScore(result);

    return move_score + result_score;
}

fn getAverageScore(score: i32) i32 {
    const round: u8 = 3;
    return @divFloor(score, round);
}

pub fn main() !void {
    std.debug.print("day 2 second project \n", .{});
    const filename = "enum.txt";

    std.debug.print("{s}\n", .{filename});

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    defer arena.deinit();

    const allocator = arena.allocator();

    const read_file = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_file);

    // try std.io.getStdOut().writeAll(read_file); // write out the contents of the file

    var iterate_through_file = std.mem.tokenize(u8, read_file, "\n");

    var general_total_score: i32 = 0;

    while (iterate_through_file.next()) |content| {
        // std.debug.print("{s}\n", .{content});
        const first_turn: Moves = try handleMoveExec(content[2]); // operator move

        const second_turn: Moves = try handleOtherMoveExec(content[0]); // the opponent move

        std.debug.print("{}: {}\n", .{ first_turn, second_turn });
        const result: Result = computeResult(first_turn, second_turn);
        std.debug.print("the result from the round {}\n", .{result});
        const total_score:i32 = calcTotalScore(first_turn, result);
        std.debug.print("the score for this round becomes {}\n ", .{total_score});
        general_total_score += total_score;
    }
    const a_score = getAverageScore(general_total_score);
    std.debug.print(" the average score becomes {}\n", .{a_score});
    std.debug.print("the final score for all rounds becomes {}\n", .{general_total_score});
}
