require_relative "workspace"

class CmdParser
    def initialize(options)
        @options = options 
    end

    def parse(args)
        if args.size < 1 
            abort_on_err "please give one command among #{@options}"
        end

        unless OPTIONS.include?(args[0])
            abort_on_err "unknown command #{args[0]}"
        end

        self.send "parse_#{args[0]}", args[1..]
    end

private
    def get_current_workspace
        unless File.exists? ".canoe"
            abort_on_err "not in a canoe workspace"
        end

        name = Dir.pwd.split("/")[-1]
        mode = File.exists?("src/main.cpp") ? :bin : :lib

        Dir.chdir('..') {
            return WorkSpace.new(name, mode)
        }
    end

    def parse_new(args)
        if args.size < 1
            abort_on_err "not enough arguments to canoe new"
        end

        name = args[0]
        if args[1] == nil
            WorkSpace.new(name, :bin).new
        elsif args[1].start_with?("--")
            mode = args[1][2..]
            if mode == "bin" || mode == "lib"
                WorkSpace.new(name, mode.to_sym).new
                return
            end
            abort_on_err "unknown option #{args[1]}"
        else
            abort_on_err "unknown option #{args[1]}"
        end
    end

    def parse_add(args)
        if args.size < 1
            abort_on_err "it's not reasonable to add a component with no name given"
        end

        get_current_workspace.add args
   end
    
    def parse_build(args)
        get_current_workspace.build
    end
    
    def parse_run(args)
        get_current_workspace.run args
    end
    
    def parse_clean(args)
        get_current_workspace.clean
    end
    
    def parse_help(args)
        WorkSpace.help
    end

    def abort_on_err(err)
        abort <<~ERR
            Error:
                #{err}
            try 'canoe help' for more information
        ERR
    end
end
