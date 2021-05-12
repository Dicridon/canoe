module Canoe
  class WorkSpace
    def run(args)
      return if @mode == :lib

      return unless build []
      
      args = args.join ' '
      issue_command "#{@target_short}/#{@name} #{args}"
    end
  end
end
