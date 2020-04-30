require_relative "workspace"
require_relative "cmd"
require_relative "source_files"

# OPTIONS = ["new", "build", "run", "clean", "help", "add", "generate"]
OPTIONS = ARGV[0].split
cmd = CmdParser.new OPTIONS
cmd.parse ARGV[1..]