require_relative 'util'

##
# class Compiler
#   Storing compiler name in String and flags as an array
module Canoe
  class Compiler
    include SystemCommand

    attr_reader :name, :flags

    ##
    # @name: String
    # @flgs: Array of String
    def initialize(name, compiling_flags, linking_flags)
      @name = name
      @linking_flags = linking_flags
      @compiling_flags = compiling_flags
    end

    def compiling_flags_as_str
      @compiling_flags.join ' '
    end

    def linking_flags_as_str
      @linking_flags.join ' '
    end

    def append_compiling_flag(flag)
      @compiling_flags << flag
    end

    def append_linking_flag(flag)
      @linking_flags << flag
    end

    def compile(src, out)
      issue_command "#{name} -o #{out} #{compiling_flags_as_str} -c #{src}"
    end

    def link_executable(out, objs)
      issue_command "#{name} -o #{out} #{objs.join(' ')} #{linking_flags_as_str}"
    end

    def link_shared(out, objs)
      issue_command "#{name} -shared -o #{out}.so #{objs.join(' ')} #{linking_flags_as_str}"
    end
  end
end
