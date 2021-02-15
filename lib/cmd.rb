require_relative "workspace/workspace"
require_relative "err"
require_relative "config_reader"

##
# class CmdParser
#   Parsing command arguments passed to canoe
class CmdParser
  include Err

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

  def get_current_workspace
    abort_on_err "not in a canoe workspace" unless File.exists? ".canoe"
    config = ConfigReader.extract_flags("config.json")

    src_sfx = config["source-suffix"] ? config["source-suffix"] : "cpp"
    hdr_sfx = config["header-suffix"] ? config["header-suffix"] : "hpp"

    name = Dir.pwd.split("/")[-1]
    mode = File.exists?("src/main.#{src_sfx}") ? :bin : :lib

    Dir.chdir("..") do
      return WorkSpace.new(name, mode, src_sfx, hdr_sfx)
    end
  end

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

  def parse_dep(args)
    get_current_workspace.dep
  end

  def parse_clean(args)
    get_current_workspace.clean
  end

  def parse_test(args)
    get_current_workspace.test args
  end

  def parse_version(args)
    WorkSpace.version
  end

  def parse_help(args)
    WorkSpace.help
  end

  def parse_update(args)
    get_current_workspace.update
  end

  def parse_make(args)
    get_current_workspace.make
  end
end
