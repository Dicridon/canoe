require_relative 'workspace/workspace'
require_relative 'cmd'
require_relative 'source_files'

module Canoe
  ##
  # Main class for building a canoe project
  class Builder
    def initialize
      options = %w[new add build generate make run dep clean version help update test]
      @cmd = CmdParser.new options
    end

    def parse(args)
      @cmd.parse args
    end
  end
end
