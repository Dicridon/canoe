require_relative "workspace"
require_relative "cmd"
require_relative "source_files"

class Canoe
  def initialize
    options = ["new", "build", "run", "clean", "help", "add", "generate", "deps", "version"]
    @cmd = CmdParser.new options
  end

  def parse(args)
      @cmd.parse args
  end
end
