require_relative "workspace/workspace"
require_relative "cmd"
require_relative "source_files"

module Canoe
  class Builder
    def initialize
      options = ["new",
                 "add",
                 "build",
                 "generate",
                 "make",
                 "run",
                 "dep",
                 "clean",
                 "version",
                 "help",
                 "update",
                 "test"]
      @cmd = CmdParser.new options
    end

    def parse(args)
      @cmd.parse args
    end
  end
end


a = [1, 2, 3]
b = a[0..]

