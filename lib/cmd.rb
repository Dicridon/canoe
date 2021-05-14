require_relative 'workspace/workspace'
require_relative 'util'
require_relative 'config_reader'

##
# class CmdParser
#   Parsing command arguments passed to canoe
module Canoe
  class CmdParser
    include Err
    include WorkSpaceUtil

    def initialize(options)
      @options = options
    end

    def parse(args)
      if args.size < 1
        abort_on_err "please give one command among #{@options.join(", ")}"
      end

      unless @options.include?(args[0])
        abort_on_err "unknown command #{args[0]}"
      end

      self.send "parse_#{args[0]}", args[1..]
    end

    private
    def parse_new(args)
      abort_on_err "not enough arguments to canoe new" if args.size < 1

      name, mode = nil, "bin"
      suffixes = ["cpp", "hpp"]

      args.each do |arg|
        case arg
        when "--bin", "--lib"
          mode = arg[2..]
        when /--suffix=(\w+)\:(\w+)/
          suffixes[0], suffixes[1] = $1, $2
        else
          name = arg unless name
        end
      end

      abort_on_err('please give a name to this project') unless name
      WorkSpace.new(name, mode.to_sym, suffixes[0], suffixes[1], true).new
    end

    def parse_add(args)
      if args.size < 1
        abort_on_err "it's not reasonable to add a component with no name given"
      end

      current_workspace.add args
    end

    def parse_build(args)
      options = {[] => 'target', ['all'] => 'all', ['test'] => 'test', ['base'] => 'base'}
      abort_on_err "Unkown subcommand #{args.join(" ").red}" unless options.include?(args)
      current_workspace.build options[args]
    end

    def parse_generate(args)
      current_workspace.generate
    end

    def parse_run(args)
      current_workspace.run args
    end

    def parse_dep(args)
      current_workspace.dep
    end

    def parse_clean(args)
      options = {
        [] => 'all', ['all'] => 'all',
        ['target'] => 'target', ['tests'] => 'tests', ['obj'] => 'obj'
      }
      abort_on_err "Unkown subcommand #{args.join(" ").red}" unless options.include?(args)
      current_workspace.clean options[args]
    end

    def parse_test(args)
      current_workspace.test args
    end

    def parse_version(args)
      WorkSpace.version
    end

    def parse_help(args)
      WorkSpace.help
    end

    def parse_update(args)
      current_workspace.update
    end

    def parse_make(args)
      current_workspace.make
    end
  end
end
