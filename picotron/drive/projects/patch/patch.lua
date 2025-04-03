--[[pod_format="raw",created="2025-04-03 16:36:55",modified="2025-04-03 16:36:57",revision=1]]

--[[
  TODOs:
  - Support writing patches
    - Implementation ideas:
      - MVP maybe just a `searchReplace(filePath, search, replace)` function.
      - Could be simple git-diff, but git-diffs with line numbers are prone to
        break on OS updates.
      - Maybe support git-diffs without line numbers like Aider does?
        - Should probably be a function `applyDiff(diff, expectedMatchCount)`
          that uses `expectedMatchCount` to ensure a warning is raised when
          updating Picotron, and the regex suddenly returns more matches than
          expected.
        - This method might not be as nice as search-replace when just adding
          code, as you'll need to include irrelevant code in both the search
          and replace strings. With `searchReplace` I suspect regexes will
          allow you to use groups to mark the code to edit/place to insert,
          so you don't need to specify the marker-code in the replace-statement
          too.
  - Support applying patches
    - Support selecting patches to apply on startup
  - GUI for enabling/disabling individual patches
    - Just adds/removes the patches to /appdata/
]]
