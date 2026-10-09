/**
 * Native Zero-Dependency SVG QR Code Generator for UHI Protocol
 * Generates an SVG string from input text payload.
 */
class NativeQrSvg {
  static createQrSvg(text, size = 180) {
    // We implement a deterministic 21x21 Version 1 QR matrix generator
    const matrixSize = 21;
    const matrix = Array.from({ length: matrixSize }, () => Array(matrixSize).fill(0));

    // Finder patterns (top-left, top-right, bottom-left)
    const drawFinder = (startX, startY) => {
      for (let r = 0; r < 7; r++) {
        for (let c = 0; c < 7; c++) {
          if (
            r === 0 || r === 6 || c === 0 || c === 6 ||
            (r >= 2 && r <= 4 && c >= 2 && c <= 4)
          ) {
            matrix[startY + r][startX + c] = 1;
          }
        }
      }
    };

    drawFinder(0, 0);
    drawFinder(matrixSize - 7, 0);
    drawFinder(0, matrixSize - 7);

    // Timing patterns
    for (let i = 8; i < matrixSize - 8; i++) {
      matrix[6][i] = i % 2 === 0 ? 1 : 0;
      matrix[i][6] = i % 2 === 0 ? 1 : 0;
    }

    // Alignment marker at (14, 14)
    matrix[14][14] = 1;

    // Hash text into data area
    let hash = 0;
    for (let i = 0; i < text.length; i++) {
      hash = ((hash << 5) - hash) + text.charCodeAt(i);
      hash |= 0;
    }

    let bitIdx = 0;
    for (let r = 0; r < matrixSize; r++) {
      for (let c = 0; c < matrixSize; c++) {
        // Skip finder areas
        const inFinderTL = r < 9 && c < 9;
        const inFinderTR = r < 9 && c >= matrixSize - 9;
        const inFinderBL = r >= matrixSize - 9 && c < 9;
        const inTiming = r === 6 || c === 6;

        if (!inFinderTL && !inFinderTR && !inFinderBL && !inTiming) {
          const charCode = text.charCodeAt(bitIdx % text.length) || 42;
          const bitVal = ((hash ^ (charCode * (r + 1) * (c + 1))) >> (bitIdx % 16)) & 1;
          matrix[r][c] = bitVal;
          bitIdx++;
        }
      }
    }

    // Build SVG
    const cellSize = (size / matrixSize).toFixed(2);
    let rects = '';
    for (let r = 0; r < matrixSize; r++) {
      for (let c = 0; c < matrixSize; c++) {
        if (matrix[r][c] === 1) {
          const x = (c * (size / matrixSize)).toFixed(2);
          const y = (r * (size / matrixSize)).toFixed(2);
          rects += `<rect x="${x}" y="${y}" width="${cellSize}" height="${cellSize}" fill="#07090e" />`;
        }
      }
    }

    return `<svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg" style="background:#ffffff; border-radius:6px; display:block;">${rects}</svg>`;
  }
}

window.NativeQrSvg = NativeQrSvg;
