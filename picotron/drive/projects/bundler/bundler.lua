--[[
  bundler <my-script.lua>

  TODOs:
  - Process:
    - Takes a Lua file
    - creates a .p64 cart
    - recursively finds all includes
    - copies all dependencies to cart
  - I believe include statements just need to have leading `/` removed if files
    are copied into the cart such that the cart becomes the new root for their
    paths.
  - Should the bundler also generate an installer cart?
    - What is the best UX for downloading apps and libs?
    - Apps are probably nicer through the package manager, but I'm guessing
      all apps won't be there.
      - It would also be nice to be able to send an installer to a friend.
    - For libs I'm guessing the best UX is finding a `load #react-installer`
      command on the BBS page for react, and then simply running that in the
      terminal.
      - Find out how this plays into the package manager
        - Should the package manager take essentially a package.json with a
          "post-install" script, or?
        - For some reason I'm guessing stand-alone installer have their uses
          but also that a higher level API through the package manager has its
          merits too?
          - Or maybe it's not weird that the package manager just calls an
            install script? Too unsafe?
]]
