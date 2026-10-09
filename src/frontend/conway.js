/**
 * Conway Automaton Engine for Web 4.0 Autonomic Grid (16x16)
 */
class ConwayGrid {
  constructor(canvasId, onUpdateCallback) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    this.width = 16;
    this.height = 16;
    this.totalCells = 256;
    this.cellSize = this.canvas.width / this.width;
    this.grid = new Array(this.totalCells).fill(false);
    this.generation = 0;
    this.timer = null;
    this.onUpdateCallback = onUpdateCallback;

    this.initDefaultPattern();
    this.bindEvents();
    this.render();
  }

  initDefaultPattern() {
    this.grid.fill(false);
    // Center Glider
    this.grid[5 * 16 + 6] = true;
    this.grid[6 * 16 + 7] = true;
    this.grid[7 * 16 + 5] = true;
    this.grid[7 * 16 + 6] = true;
    this.grid[7 * 16 + 7] = true;

    // Small oscillator pods
    this.grid[2 * 16 + 2] = true;
    this.grid[2 * 16 + 3] = true;
    this.grid[3 * 16 + 2] = true;
    this.grid[3 * 16 + 3] = true;

    this.grid[12 * 16 + 12] = true;
    this.grid[12 * 16 + 13] = true;
    this.grid[13 * 16 + 12] = true;
    this.grid[13 * 16 + 13] = true;

    this.generation = 0;
  }

  seedGlider() {
    this.grid.fill(false);
    this.grid[1 * 16 + 2] = true;
    this.grid[2 * 16 + 3] = true;
    this.grid[3 * 16 + 1] = true;
    this.grid[3 * 16 + 2] = true;
    this.grid[3 * 16 + 3] = true;
    this.generation = 0;
    this.notify();
    this.render();
  }

  seedAcorn() {
    this.grid.fill(false);
    this.grid[7 * 16 + 5] = true;
    this.grid[8 * 16 + 7] = true;
    this.grid[9 * 16 + 4] = true;
    this.grid[9 * 16 + 5] = true;
    this.grid[9 * 16 + 8] = true;
    this.grid[9 * 16 + 9] = true;
    this.grid[9 * 16 + 10] = true;
    this.generation = 0;
    this.notify();
    this.render();
  }

  countNeighbors(x, y) {
    let count = 0;
    for (let dy = -1; dy <= 1; dy++) {
      for (let dx = -1; dx <= 1; dx++) {
        if (dx === 0 && dy === 0) continue;
        const nx = (x + dx + this.width) % this.width;
        const ny = (y + dy + this.height) % this.height;
        if (this.grid[ny * this.width + nx]) {
          count++;
        }
      }
    }
    return count;
  }

  step() {
    const next = new Array(this.totalCells).fill(false);
    let alive = 0;

    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        const idx = y * this.width + x;
        const neighbors = this.countNeighbors(x, y);
        const isCurrentAlive = this.grid[idx];
        const nextState = isCurrentAlive ? (neighbors === 2 || neighbors === 3) : (neighbors === 3);
        next[idx] = nextState;
        if (nextState) alive++;
      }
    }

    this.grid = next;
    this.generation++;
    this.notify(alive);
    this.render();
  }

  toggleRun() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
      return false;
    } else {
      this.timer = setInterval(() => this.step(), 400);
      return true;
    }
  }

  getStats(knownAlive) {
    const alive = knownAlive !== undefined ? knownAlive : this.grid.filter(Boolean).length;
    const dead = this.totalCells - alive;
    const densityBps = Math.floor((alive * 10000) / this.totalCells);
    const multiplierBps = 10000 + Math.floor((alive * 5000) / this.totalCells);
    const entropy = Math.floor((4 * alive * dead) / this.totalCells);

    return {
      generation: this.generation,
      alive,
      dead,
      densityPct: (densityBps / 100).toFixed(2),
      multiplier: (multiplierBps / 10000).toFixed(2),
      multiplierBps,
      entropy
    };
  }

  notify(knownAlive) {
    if (this.onUpdateCallback) {
      this.onUpdateCallback(this.getStats(knownAlive));
    }
  }

  bindEvents() {
    this.canvas.addEventListener('click', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      const clickY = e.clientY - rect.top;
      const col = Math.floor(clickX / this.cellSize);
      const row = Math.floor(clickY / this.cellSize);
      if (col >= 0 && col < this.width && row >= 0 && row < this.height) {
        const idx = row * this.width + col;
        this.grid[idx] = !this.grid[idx];
        this.notify();
        this.render();
      }
    });
  }

  render() {
    this.ctx.fillStyle = '#05070a';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    // Draw grid lines
    this.ctx.strokeStyle = 'rgba(56, 189, 248, 0.15)';
    this.ctx.lineWidth = 1;
    for (let i = 0; i <= this.width; i++) {
      this.ctx.beginPath();
      this.ctx.moveTo(i * this.cellSize, 0);
      this.ctx.lineTo(i * this.cellSize, this.canvas.height);
      this.ctx.stroke();

      this.ctx.beginPath();
      this.ctx.moveTo(0, i * this.cellSize);
      this.ctx.lineTo(this.canvas.width, i * this.cellSize);
      this.ctx.stroke();
    }

    // Draw living cells with glow
    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        const idx = y * this.width + x;
        if (this.grid[idx]) {
          const px = x * this.cellSize;
          const py = y * this.cellSize;

          this.ctx.fillStyle = '#00f3ff';
          this.ctx.shadowColor = '#00f3ff';
          this.ctx.shadowBlur = 10;
          this.ctx.fillRect(px + 2, py + 2, this.cellSize - 4, this.cellSize - 4);
          this.ctx.shadowBlur = 0;
        }
      }
    }
  }
}

window.ConwayGrid = ConwayGrid;
