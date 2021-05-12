module Canoe
  class WorkSpace
    def run(args)
      return if @mode == :lib

      build []
      args = args.join ' '
      issue_command "./target/#{@name} #{args}"
    end
  end
end
