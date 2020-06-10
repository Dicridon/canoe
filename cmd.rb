require_relative "workspace"
require_relative "err"

class CmdParser
    include Err
    def initialize(options)
        @options = options 
    end

    def parse(args)
        if args.size < 1 
            abort_on_err "please give one command among #{@options.join(', ')}"
        end

        unless @options.include?(args[0])
            abort_on_err "unknown command #{args[0]}"
        end

        self.send "parse_#{args[0]}", args[1..]
    end

private
    def get_current_workspace
        abort_on_err "not in a canoe workspace" unless File.exists? ".canoe"

        name = Dir.pwd.split("/")[-1]
        mode = File.exists?("src/main.cpp") ? :bin : :lib

        Dir.chdir('..') do
            return WorkSpace.new(name, mode)
        end
    end

    def parse_new(args)
        if args.size < 1
            abort_on_err "not enough arguments to canoe new"
        end
        abort_on_err("too many args to 'new'") if args.length > 2
        name, mode = nil, "bin"
        suffixes = ["cpp", "hpp"]
        args.each do |arg|
            case arg
            when '--bin', '--lib'
                mode = arg[2..]
            when /--suffix=(\w+)\:(\w+)/
                suffixes[0], suffixes[1] = $1, $2
            else
                name = arg unless name
            end
        end
        abort_on_err("please give a name to this project") unless name
        WorkSpace.new(name, mode.to_sym, suffixes[0], suffixes[1]).new
    end

    def parse_add(args)
        if args.size < 1
            abort_on_err "it's not reasonable to add a component with no name given"
        end

        get_current_workspace.add args
   end
    
    def parse_build(args)
        get_current_workspace.build args
    end

    def parse_generate(args)
        get_current_workspace.generate
    end
    
    def parse_run(args)
        get_current_workspace.run args
    end
    
    def parse_clean(args)
        get_current_workspace.clean
    end

    def parse_version(args)
        puts <<~VER
        canoe v0.2
        For features in this version, please visit https://github.com/Dicridon/canoe
        Currently, canoe can do below:
            - project creation
            - project auto build and run (works like Cargo for Rust)
            - project structure management
        by XIONG Ziwei
        VER
    end
    
    def parse_help(args)
        WorkSpace.help
    end
end
