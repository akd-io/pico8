--[[
  Zod clone
  https://zod.dev/

  Boundaries where zod could be useful:
  - UI forms
  - Third-party process communication
  - File system
    - AppData (could be tampered with)
    - Shared: Third party file communication
  - Configuration files, user input, and could be tampered
  - Command-line arguments, user input, machine input

  TODOs:
  - Find out if the lua type annotations are flexible enough for a task like
    this. Maybe it'll be validate, not parse, after all.
]]
