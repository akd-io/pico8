import { shrinko8Builtins, picolsBuiltins } from "./builtins";

// Find the builtins that are in shrinko8 but not in picols
const shrinko8Only = shrinko8Builtins.filter(
  (builtin) => !picolsBuiltins.includes(builtin)
);
console.log("Shrinko8 only builtins:", shrinko8Only);

// Find the builtins that are in picols but not in shrinko8
const picolsOnly = picolsBuiltins.filter(
  (builtin) => !shrinko8Builtins.includes(builtin)
);
console.log("Picols only builtins:", picolsOnly);

/*
Output:
Shrinko8 only builtins: [
  "inext", "load", "ls", "rawequal", "holdframe", "_set_fps", "_update_buttons", "_mark_cpu", "_startframe",
  "_update_framerate", "_set_mainloop_exists", "_map_display", "_get_menu_item_selected",
  "_pausemenu", "set_draw_slice", "tostring"
]
Picols only builtins: [ "info", "rawequals", "self", "coyield", "?" ]
*/
