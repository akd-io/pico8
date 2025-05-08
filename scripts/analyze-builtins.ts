import {
  shrinko8Builtins,
  picolsBuiltins,
  fandomHeaderArticleSectionHeader3Builtins,
  akdBuiltins,
} from "./builtins";

/*
Notes:
"rand" from the pico-8 header is nil, and shouldn't be added.
Picols's [ "rawequals", "self", "coyield", "?" ] all return nil when type()'d in pico8.

Output:
Shrinko8 only builtins: []
Picols only builtins: [ "rawequals", "self", "coyield", "?" ]
Fandom only builtins: [ "rand" ]
AKD only builtins: [
  "__flip", "__trace", "__type", "_menuitem", "backup", "bbsreq", "cd", "dir", "exit", "export", "folder",
  "help", "import", "install_demos", "install_games", "keyconfig", "login", "logout", "mkdir", "radio",
  "reboot", "save", "scoresub", "shutdown", "splore"
]
*/

const shrinko8Only = shrinko8Builtins.filter(
  (builtin) =>
    !picolsBuiltins.includes(builtin) &&
    !fandomHeaderArticleSectionHeader3Builtins.includes(builtin) &&
    !akdBuiltins.includes(builtin)
);
console.log("Shrinko8 only builtins:", shrinko8Only);

const picolsOnly = picolsBuiltins.filter(
  (builtin) =>
    !shrinko8Builtins.includes(builtin) &&
    !fandomHeaderArticleSectionHeader3Builtins.includes(builtin) &&
    !akdBuiltins.includes(builtin)
);
console.log("Picols only builtins:", picolsOnly);

const fandomOnly = fandomHeaderArticleSectionHeader3Builtins.filter(
  (builtin) =>
    !shrinko8Builtins.includes(builtin) &&
    !picolsBuiltins.includes(builtin) &&
    !akdBuiltins.includes(builtin)
);
console.log("Fandom only builtins:", fandomOnly);

const akdOnly = akdBuiltins.filter(
  (builtin) =>
    !shrinko8Builtins.includes(builtin) &&
    !picolsBuiltins.includes(builtin) &&
    !fandomHeaderArticleSectionHeader3Builtins.includes(builtin)
);
console.log("AKD only builtins:", akdOnly);
