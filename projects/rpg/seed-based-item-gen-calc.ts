let twoTo20 = Math.pow(2, 20);
let twoTo32 = Math.pow(2, 32);
let rest = twoTo32 - twoTo20;
let shareOfRest = rest / 16;

console.log("| " + 0 + " | " + twoTo20 + " | " + (twoTo20 - 0) + " |");
for (let i = 0; i < 16; i++) {
  let a = twoTo20 + shareOfRest * i;
  let b = twoTo20 + shareOfRest * (i + 1);
  console.log("| " + a + " | " + b + " | " + (b - a) + " |");
}
