const std = @import("std");
const comphash = @import("comphash");
const items = @import("items.zig");

// Number of iterations to run the benchmark for each map size
const ITERS = 1_000_000;

/// Sample a random subset of string keys from the pairs array
fn randomNumbers(allocator: std.mem.Allocator) ![]const usize {
    var prng = std.Random.DefaultPrng.init(0xDEADBEEF);
    // allocate a slice of string‐slices
    const out = try allocator.alloc(usize, ITERS);
    for (0..ITERS) |i| {
        out[i] = prng.random().int(usize);
    }
    return out;
}

// Extract the items from the items.zig file
const one_hundred = items.one_hundred;
const one_thousand = items.one_thousand;
const two_thousand = items.two_thousand;

// Define the comptime hash map
const Map = comphash.ComptimeHashMap(u32, null, null, null);

// Warmup the comptime map by getting 1000 items
fn warmupComptimeMap(numbers: []const usize, map: Map) void {
    const mapAsSlice = map.toSlice();
    for (0..1000) |i| {
        _ = map.get(mapAsSlice[numbers[i] % mapAsSlice.len].key);
    }
}

// Warmup the string map by getting 1000 items
fn warmupStringMap(numbers: []const usize, map: std.StaticStringMap(u32)) void {
    const keys = map.keys();
    for (0..1000) |i| {
        _ = map.get(keys[numbers[i] % keys.len]);
    }
}

// Initialize the maps with the items from the items.zig file
const map_one_hundred = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk Map.init(one_hundred);
};

const map_one_thousand = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk Map.init(one_thousand);
};

const map_two_thousand = blk: {
    @setEvalBranchQuota(20_000_000);
    break :blk Map.init(two_thousand);
};

// As a comparison, we also initialize the maps with the items
// from the items.zig file
const string_map_one_hundred = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk std.StaticStringMap(u32).initComptime(one_hundred);
};

const string_map_one_thousand = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk std.StaticStringMap(u32).initComptime(one_thousand);
};

const string_map_two_thousand = blk: {
    @setEvalBranchQuota(20_000_000);
    break :blk std.StaticStringMap(u32).initComptime(two_thousand);
};

// Display the metrics for the given object, including the object
// name, size, iterations, duration, and average duration per call.
fn displayMetrics(duration: i128, obj: []const u8, size: usize) void {
    std.debug.print("================ Performance Metrics ================\n", .{});
    std.debug.print("Object: {s}\n", .{obj});
    std.debug.print("Size: {d} items\n", .{size});
    std.debug.print("Iterations: {d}\n", .{ITERS});
    std.debug.print("Duration: {d} ns\n", .{duration});
    std.debug.print("Average duration: {d} ns per call\n", .{@divFloor(duration, ITERS)});
    std.debug.print("=======================================================\n", .{});
}

// Benchmark the get() function for the comptime map for the given
// object, key, and size.
fn runComptimeMapBenchmark(map: Map, size: usize, numbers: []const usize) void {
    warmupComptimeMap(numbers, map);
    const mapAsSlice = map.toSlice();
    var dur: i128 = 0;
    for (0..ITERS) |i| {
        const key = mapAsSlice[numbers[i] % size].key;
        const start = std.time.nanoTimestamp();
        _ = map.get(key);
        dur += std.time.nanoTimestamp() - start;
    }
    displayMetrics(dur, "ComptimeHashMap.get", size);
}

// Benchmark the get() function for the string map for the given
// object, key, iterations, and size.
fn runStringMapBenchmark(map: std.StaticStringMap(u32), size: usize, numbers: []const usize) void {
    warmupStringMap(numbers, map);
    var dur: i128 = 0;
    const keys = map.keys();
    for (0..ITERS) |i| {
        const key = keys[numbers[i] % size];
        const start = std.time.nanoTimestamp();
        _ = map.get(key);
        dur += std.time.nanoTimestamp() - start;
    }
    displayMetrics(dur, "StaticStringMap.get", size);
}

// Benchmark the get() function for the comptime map and the string map
// for 100 and 1000 items.
pub fn main() !void {
    const numbers = try randomNumbers(std.heap.page_allocator);
    std.debug.print("numbers: {any}\n", .{numbers[0..15]});

    // Benchmark get() on the 100-item map (comptime map)
    runComptimeMapBenchmark(map_one_hundred, 100, numbers);

    // Benchmark get() on the 1000-item map (comptime map)
    runComptimeMapBenchmark(map_one_thousand, 1000, numbers);

    // Benchmark get() on the 2000-item map (comptime map)
    runComptimeMapBenchmark(map_two_thousand, 2000, numbers);

    // Benchmark get() on the 100-item map (string map)
    runStringMapBenchmark(string_map_one_hundred, 100, numbers);

    // Benchmark get() on the 1000-item map (string map)
    runStringMapBenchmark(string_map_one_thousand, 1000, numbers);

    // Benchmark get() on the 2000-item map (string map)
    runStringMapBenchmark(string_map_two_thousand, 2000, numbers);
}
