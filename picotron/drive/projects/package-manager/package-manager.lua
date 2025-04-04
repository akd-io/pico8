--[[
  Package Manager app.
  TODOs:
  - Lists apps from BBS.
    - bbs:// protocol supports "new" and ??
    - bbs:// seems slow. If true, cache metadata and maybe small cart icons.
    - Check if `cp` command supports bbs:// protocol and as possible to download and unzip carts to get their metadata/icon without having to load the cart as that might override other work.
    - Maybe ship the app with precompiled metadata not available through bbs:// protocol.
      - list of most liked carts on bbs. (Cart ID + icons)
  - Lists installed apps.
  - Lets you install, uninstall, update.
  - Lets you switch sandbox mode if possible.
  - Lets you load listed carts both sandboxed (default) and unsandboxed (load -u).
  - Maybe libraries can be saves to a special folder like `node_modules`.
    - As package manager knows what modules are installed, we could
      auto-generate types for a special `require` function.
]]

-- We can auto-generate types for packages as such:
---@param packageName "package1" | "package2"
function require(packageName) end

-- Developer experience:
require("package1") -- OK - CTRL+Space even auto-completes.
require("package2") -- OK
require("package3") -- param-type-mismatch: Cannot assign `string` to parameter `"package1"|"package2"`.

-- We can also list packages one per line like this:
---@param packageName "package1"
---          | "package2"
---          | "package3"
function anotherRequire(packageName) end

-- Developer experience:
anotherRequire("package1") -- OK
anotherRequire("package2") -- OK
anotherRequire("package3") -- OK
anotherRequire("package4") -- param-type-mismatch: Cannot assign `string` to parameter `"package1"|"package2"|"package3"`.
