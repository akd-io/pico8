include("/lib/printPrint.lua")

local function printPrintUsage()
  printPrint("Usage: touch <path/to/file>")
end

cd(env().path)
local rawInputPath = env().argv[1]
local inputPath = fullpath(rawInputPath)

if inputPath == nil then
  printPrintUsage()
  exit(0)
end

local fileType = fstat(inputPath)
if fileType != nil then
  local prettyFileType = fileType == "folder" and "directory" or fileType
  printPrint(prettyFileType .. " already exists")
  exit(1)
end

-- TODO: Handle missing directories in path. Currently just fails while pretending it made the file.

store(inputPath, "")
print("Made file: " .. rawInputPath)
