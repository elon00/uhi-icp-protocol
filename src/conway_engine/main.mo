import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Text "mo:base/Text";

shared actor class ConwayEngine() = this {

  public type GridStats = {
    generation : Nat;
    alive_cells : Nat;
    dead_cells : Nat;
    density_basis_points : Nat;
    dynamic_multiplier_basis_points : Nat;
    entropy_score : Nat;
  };

  private let WIDTH : Nat = 16;
  private let HEIGHT : Nat = 16;
  private let TOTAL_CELLS : Nat = 256;

  private var generation_count : Nat = 0;
  private var grid : [var Bool] = Array.init<Bool>(256, false);

  // Initialize with Gosper Glider / Beacon hybrid for active autonomic dynamics
  private func initializeGrid() {
    // Center glider
    grid[5 * 16 + 6] := true;
    grid[6 * 16 + 7] := true;
    grid[7 * 16 + 5] := true;
    grid[7 * 16 + 6] := true;
    grid[7 * 16 + 7] := true;

    // Pulsar seeds / oscillators
    grid[2 * 16 + 2] := true;
    grid[2 * 16 + 3] := true;
    grid[3 * 16 + 2] := true;
    grid[3 * 16 + 3] := true;

    grid[12 * 16 + 12] := true;
    grid[12 * 16 + 13] := true;
    grid[13 * 16 + 12] := true;
    grid[13 * 16 + 13] := true;
  };

  initializeGrid();

  private func countNeighbors(x : Nat, y : Nat) : Nat {
    var count : Nat = 0;
    var dy : Int = -1;
    while (dy <= 1) {
      var dx : Int = -1;
      while (dx <= 1) {
        if (not (dx == 0 and dy == 0)) {
          let nx = (Int.abs((x : Int) + dx + 16)) % 16;
          let ny = (Int.abs((y : Int) + dy + 16)) % 16;
          let idx = (ny * 16) + nx;
          if (grid[idx]) {
            count += 1;
          };
        };
        dx += 1;
      };
      dy += 1;
    };
    count
  };

  public shared func step_generation() : async GridStats {
    let nextGrid = Array.init<Bool>(TOTAL_CELLS, false);
    var alive : Nat = 0;

    var y : Nat = 0;
    while (y < HEIGHT) {
      var x : Nat = 0;
      while (x < WIDTH) {
        let idx = (y * WIDTH) + x;
        let neighbors = countNeighbors(x, y);
        let currentState = grid[idx];

        let nextState = if (currentState) {
          neighbors == 2 or neighbors == 3
        } else {
          neighbors == 3
        };

        nextGrid[idx] := nextState;
        if (nextState) {
          alive += 1;
        };
        x += 1;
      };
      y += 1;
    };

    var i : Nat = 0;
    while (i < TOTAL_CELLS) {
      grid[i] := nextGrid[i];
      i += 1;
    };

    generation_count += 1;
    computeStats(alive)
  };

  private func computeStats(alive : Nat) : GridStats {
    let dead = TOTAL_CELLS - alive;
    let densityBps = (alive * 10000) / TOTAL_CELLS;
    // Multiplier base: 10000 bps (1.0x). Max boost: 5000 bps (0.5x). Total 1.0x to 1.5x
    let multiplierBps = 10000 + ((alive * 5000) / TOTAL_CELLS);
    // Simple algorithmic entropy metric: 4 * alive * dead / TOTAL_CELLS
    let entropy = (4 * alive * dead) / TOTAL_CELLS;

    {
      generation = generation_count;
      alive_cells = alive;
      dead_cells = dead;
      density_basis_points = densityBps;
      dynamic_multiplier_basis_points = multiplierBps;
      entropy_score = entropy;
    }
  };

  public query func get_grid() : async [Bool] {
    Array.freeze<Bool>(grid)
  };

  public query func get_stats() : async GridStats {
    var alive : Nat = 0;
    var i : Nat = 0;
    while (i < TOTAL_CELLS) {
      if (grid[i]) { alive += 1 };
      i += 1;
    };
    computeStats(alive)
  };

  public shared func toggle_cell(x : Nat, y : Nat) : async { #Ok : Bool; #Err : Text } {
    if (x >= WIDTH or y >= HEIGHT) {
      return #Err("Coordinates out of 16x16 bounds");
    };
    let idx = (y * WIDTH) + x;
    grid[idx] := not grid[idx];
    #Ok(grid[idx])
  };

  public shared func seed_pattern(pattern_name : Text) : async GridStats {
    var i : Nat = 0;
    while (i < TOTAL_CELLS) {
      grid[i] := false;
      i += 1;
    };

    if (pattern_name == "glider") {
      grid[1 * 16 + 2] := true;
      grid[2 * 16 + 3] := true;
      grid[3 * 16 + 1] := true;
      grid[3 * 16 + 2] := true;
      grid[3 * 16 + 3] := true;
    } else if (pattern_name == "acorn") {
      grid[7 * 16 + 5] := true;
      grid[8 * 16 + 7] := true;
      grid[9 * 16 + 4] := true;
      grid[9 * 16 + 5] := true;
      grid[9 * 16 + 8] := true;
      grid[9 * 16 + 9] := true;
      grid[9 * 16 + 10] := true;
    } else {
      initializeGrid();
    };

    var alive : Nat = 0;
    var j : Nat = 0;
    while (j < TOTAL_CELLS) {
      if (grid[j]) { alive += 1 };
      j += 1;
    };
    computeStats(alive)
  };
};
