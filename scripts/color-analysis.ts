import { color, lab, hsl } from "d3-color";

const colors = [
  // Primary
  { index: 0, hex: "000000", rgb: [0, 0, 0] },
  { index: 1, hex: "1D2B53", rgb: [29, 43, 83] },
  { index: 2, hex: "7E2553", rgb: [126, 37, 83] },
  { index: 3, hex: "008751", rgb: [0, 135, 81] },

  { index: 4, hex: "AB5236", rgb: [171, 82, 54] },
  { index: 5, hex: "5F574F", rgb: [95, 87, 79] },
  { index: 6, hex: "C2C3C7", rgb: [194, 195, 199] },
  { index: 7, hex: "FFF1E8", rgb: [255, 241, 232] },

  { index: 8, hex: "FF004D", rgb: [255, 0, 77] },
  { index: 9, hex: "FFA300", rgb: [255, 163, 0] },
  { index: 10, hex: "FFEC27", rgb: [255, 236, 39] },
  { index: 11, hex: "00E436", rgb: [0, 228, 54] },

  { index: 12, hex: "29ADFF", rgb: [41, 173, 255] },
  { index: 13, hex: "83769C", rgb: [131, 118, 156] },
  { index: 14, hex: "FF77A8", rgb: [255, 119, 168] },
  { index: 15, hex: "FFCCAA", rgb: [255, 204, 170] },

  // Undocumented
  { index: -16, hex: "291814", rgb: [41, 24, 20] },
  { index: -15, hex: "111D35", rgb: [17, 29, 53] },
  { index: -14, hex: "422136", rgb: [66, 33, 54] },
  { index: -13, hex: "125359", rgb: [18, 83, 89] },

  { index: -12, hex: "742F29", rgb: [116, 47, 41] },
  { index: -11, hex: "49333B", rgb: [73, 51, 59] },
  { index: -10, hex: "A28879", rgb: [162, 136, 121] },
  { index: -9, hex: "F3EF7D", rgb: [243, 239, 125] },

  { index: -8, hex: "BE1250", rgb: [190, 18, 80] },
  { index: -7, hex: "FF6C24", rgb: [255, 108, 36] },
  { index: -6, hex: "A8E72E", rgb: [168, 231, 46] },
  { index: -5, hex: "00B543", rgb: [0, 181, 67] },

  { index: -4, hex: "065AB5", rgb: [6, 90, 181] },
  { index: -3, hex: "754665", rgb: [117, 70, 101] },
  { index: -2, hex: "FF6E59", rgb: [255, 110, 89] },
  { index: -1, hex: "FF9D81", rgb: [255, 157, 129] },
];

const newColors = colors.map((col) => {
  const rgbColor = color("#" + col.hex);
  const labColor = lab(rgbColor!);
  const hslColor = hsl(rgbColor!);
  return {
    ...col,
    lab: [labColor.l, labColor.a, labColor.b],
    hsl: [hslColor.h || 0, hslColor.s || 0, hslColor.l || 0],
  };
});

await Bun.write(
  Bun.file(__dirname + "/colors.json"),
  JSON.stringify(newColors, null, 2)
);
