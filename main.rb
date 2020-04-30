require_relative "workspace"
require_relative "cmd"
require_relative "source_files"
OPTIONS = ["new", "build", "run", "clean", "help", "add", "generate"]

cmd = CmdParser.new OPTIONS

cmd.parse ARGV
# puts "seriously?"
# d = SourceFiles.new './components'
# d.get_all {|f| f.end_with? '.cpp'}
# puts d.files